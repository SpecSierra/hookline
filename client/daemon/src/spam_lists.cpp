#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QSaveFile>

#include "call_filter.h"
#include "setting.h"
#include "spam_lists.h"

static QNetworkRequest listRequest(QUrl url) {
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "phonehook (https://github.com/SpecSierra/phonehook)");
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("X-Country-Code", "FR");
    return request;
}

spam_lists::spam_lists(QString cachePath, call_filter *filter, QObject *parent) :
    QObject(parent), m_cachePath(cachePath), m_filter(filter)
{
    m_timer.setSingleShot(true);
    connect(&m_timer, &QTimer::timeout, this, &spam_lists::check);
    check();
}

// "33162######" covers every number starting with +33 1 62, a pattern
// without "#" is a single number (or a short service number)
QStringList spam_lists::filterEntries(QString pattern) {
    if (!pattern.contains(QRegExp("^\\d+#*$")))
        return QStringList();

    QString digits = pattern;
    digits.remove('#');
    if (!pattern.endsWith('#'))
        return QStringList() << (digits.length() > 6 ? "+" + digits : digits);

    QStringList entries;
    entries << "^+" + digits;
    // French numbers may also arrive in national format
    if (digits.startsWith("33"))
        entries << "^0" + digits.mid(2);
    return entries;
}

void spam_lists::check() {
    if (setting::get("spam_lists", "true") != "true") {
        m_timer.start(3600 * 1000);
        return;
    }

    QDateTime lastUpdate = QDateTime::fromString(setting::get("spam_lists_updated", ""), Qt::ISODate);
    qint64 untilNext = lastUpdate.isValid()
            ? QDateTime::currentDateTimeUtc().msecsTo(lastUpdate.addDays(1)) : 0;

    // Lists downloaded before the entry count was recorded are refreshed
    bool complete = QFile::exists(m_cachePath) && setting::get("spam_lists_count", "") != "";
    if (untilNext > 0 && complete)
        m_timer.start(untilNext);
    else
        download();
}

void spam_lists::download() {
    qDebug() << "spam lists: updating";
    m_entries.clear();
    m_pending = 0;
    m_failed = false;
    m_patterns = 0;
    QNetworkReply *reply = m_net.get(listRequest(QUrl("https://app.saracroche.org/api/v2/lists")));
    connect(reply, &QNetworkReply::finished, [this, reply]() { gotIndex(reply); });
}

void spam_lists::gotIndex(QNetworkReply *reply) {
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "spam lists: index failed" << reply->errorString();
        m_timer.start(3600 * 1000);
        return;
    }

    for (const QJsonValue &value : QJsonDocument::fromJson(reply->readAll()).array()) {
        QJsonObject list = value.toObject();
        // Only block lists: the large "allow" list is for caller identification
        if (list.value("channel").toString() != "phone" || list.value("type").toString() != "block")
            continue;

        ++m_pending;
        QNetworkReply *listReply = m_net.get(listRequest(QUrl(list.value("download_url").toString())));
        connect(listReply, &QNetworkReply::finished, [this, listReply]() { gotList(listReply); });
    }

    if (m_pending == 0)
        m_timer.start(3600 * 1000);
}

void spam_lists::gotList(QNetworkReply *reply) {
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "spam lists: download failed" << reply->errorString();
        m_failed = true;
    } else {
        // One JSON object per line: {"name": ..., "pattern": ...}
        while (!reply->atEnd()) {
            QJsonObject entry = QJsonDocument::fromJson(reply->readLine()).object();
            m_entries << filterEntries(entry.value("pattern").toString());
            ++m_patterns;
        }
    }

    if (--m_pending > 0)
        return;

    // Keep the previous lists if one download failed
    if (m_failed) {
        m_timer.start(3600 * 1000);
        return;
    }

    m_entries.removeDuplicates();
    QSaveFile cache(m_cachePath);
    if (cache.open(QIODevice::WriteOnly)) {
        cache.write(m_entries.join("\n").toUtf8());
        cache.commit();
    }
    qDebug() << "spam lists:" << m_entries.count() << "entries";

    setting::put("spam_lists_updated", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
    setting::put("spam_lists_count", QString::number(m_patterns));
    m_filter->sync();
    check();
}
