#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QSaveFile>

#include "block_lists.h"
#include "setting.h"

static const char *INDEX_URL = "https://raw.githubusercontent.com/SpecSierra/phonehook-sources/master/blocklists/index.json";

static QNetworkRequest listRequest(QUrl url) {
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Hookline (https://github.com/SpecSierra/hookline)");
    return request;
}

block_lists::block_lists(QString cacheDir, QObject *parent) :
    QObject(parent), m_cacheDir(cacheDir)
{
    m_timer.setSingleShot(true);
    connect(&m_timer, &QTimer::timeout, this, &block_lists::check);
    check();
}

// Patterns are international numbers without "+", each trailing "#" is any
// digit: "33162######" covers every number starting with +33 1 62. Numbers
// may also arrive in national format (trunk prefix instead of country code).
QStringList block_lists::filterEntries(QString pattern, QString countryCode, QString trunkPrefix) {
    if (!pattern.contains(QRegExp("^\\d+#*$")))
        return QStringList();

    QString digits = pattern;
    digits.remove('#');
    if (!pattern.endsWith('#'))
        return QStringList() << (digits.length() > 6 ? "+" + digits : digits);

    QStringList entries;
    entries << "^+" + digits;
    if (!countryCode.isEmpty() && digits.startsWith(countryCode))
        entries << "^" + trunkPrefix + digits.mid(countryCode.length());
    return entries;
}

bool block_lists::isEnabled(const QJsonObject &list) {
    QString choice = setting::get("block_list_" + list.value("id").toString(), "");
    if (choice != "")
        return choice == "true";
    QString home = setting::get("home_country", setting::get("location", ""));
    return home != "" && list.value("country").toString().compare(home, Qt::CaseInsensitive) == 0;
}

QJsonArray block_lists::index() const {
    return QJsonDocument::fromJson(setting::get("block_lists_index", "[]").toUtf8()).array();
}

QString block_lists::cachePath(const QJsonObject &list) const {
    return m_cacheDir + "/block_list_" + list.value("id").toString() + ".txt";
}

QStringList block_lists::entries() {
    QStringList entries;
    bool missing = false;
    for (const QJsonValue &value : index()) {
        QJsonObject list = value.toObject();
        if (!isEnabled(list))
            continue;
        QFile cache(cachePath(list));
        if (cache.open(QIODevice::ReadOnly))
            entries << QString::fromUtf8(cache.readAll()).split("\n", QString::SkipEmptyParts);
        else if (!m_attempted.contains(list.value("id").toString()))
            missing = true;
    }
    // A list was just enabled: fetch it now instead of tomorrow
    if (missing && m_pending == 0)
        m_timer.start(0);
    return entries;
}

void block_lists::check() {
    QDateTime lastUpdate = QDateTime::fromString(setting::get("block_lists_updated", ""), Qt::ISODate);
    qint64 untilNext = lastUpdate.isValid()
            ? QDateTime::currentDateTimeUtc().msecsTo(lastUpdate.addDays(1)) : 0;

    bool complete = true;
    for (const QJsonValue &value : index()) {
        QJsonObject list = value.toObject();
        if (isEnabled(list) && !QFile::exists(cachePath(list)))
            complete = false;
    }

    if (untilNext > 0 && complete && !index().isEmpty())
        m_timer.start(untilNext);
    else
        download();
}

void block_lists::download() {
    if (m_pending > 0)
        return;
    qDebug() << "block lists: updating";
    m_roundFailed = false;
    ++m_pending;
    QNetworkReply *reply = m_net.get(listRequest(QUrl(INDEX_URL)));
    connect(reply, &QNetworkReply::finished, [this, reply]() { gotIndex(reply); });
}

void block_lists::gotIndex(QNetworkReply *reply) {
    reply->deleteLater();
    --m_pending;

    QJsonDocument indexDoc = QJsonDocument::fromJson(reply->readAll());
    if (reply->error() != QNetworkReply::NoError || !indexDoc.isArray()) {
        qDebug() << "block lists: index failed" << reply->errorString();
        m_roundFailed = true;
        roundDone();
        return;
    }
    setting::put("block_lists_index", QString::fromUtf8(indexDoc.toJson(QJsonDocument::Compact)));

    for (const QJsonValue &value : indexDoc.array()) {
        QJsonObject list = value.toObject();
        if (!isEnabled(list))
            continue;

        QString id = list.value("id").toString();
        QJsonArray urls = list.value("urls").toArray();
        m_attempted.insert(id);
        m_listPending[id] = urls.count();
        m_listFailed[id] = false;
        m_listEntries[id].clear();
        m_listPatterns[id] = 0;

        for (const QJsonValue &url : urls) {
            ++m_pending;
            QNetworkReply *listReply = m_net.get(listRequest(QUrl(url.toString())));
            connect(listReply, &QNetworkReply::finished, [this, listReply, list]() { gotList(listReply, list); });
        }
    }

    setting::put("block_lists_updated", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    if (m_pending == 0)
        roundDone();
}

void block_lists::gotList(QNetworkReply *reply, QJsonObject list) {
    reply->deleteLater();
    --m_pending;
    QString id = list.value("id").toString();

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "block lists:" << id << "download failed" << reply->errorString();
        m_listFailed[id] = true;
        m_roundFailed = true;
    } else {
        // One JSON object per line: {"name": ..., "pattern": ...}
        QString countryCode = list.value("country_code").toString();
        QString trunkPrefix = list.value("trunk_prefix").toString();
        while (!reply->atEnd()) {
            QJsonObject entry = QJsonDocument::fromJson(reply->readLine()).object();
            m_listEntries[id] << filterEntries(entry.value("pattern").toString(), countryCode, trunkPrefix);
            ++m_listPatterns[id];
        }
    }

    if (--m_listPending[id] == 0)
        listDone(list);

    if (m_pending == 0)
        roundDone();
}

// Next round tomorrow, or in an hour if something failed
void block_lists::roundDone() {
    emit updated();
    m_timer.start((m_roundFailed ? 1 : 24) * 3600 * 1000);
}

void block_lists::listDone(const QJsonObject &list) {
    QString id = list.value("id").toString();
    // Keep the previous version if one of its files failed
    if (m_listFailed[id])
        return;

    QStringList entries = m_listEntries.take(id);
    entries.removeDuplicates();
    QSaveFile cache(cachePath(list));
    if (cache.open(QIODevice::WriteOnly)) {
        cache.write(entries.join("\n").toUtf8());
        cache.commit();
    }
    setting::put("block_list_count_" + id, QString::number(m_listPatterns[id]));
    setting::put("block_list_updated_" + id, QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    qDebug() << "block lists:" << id << entries.count() << "entries";
}
