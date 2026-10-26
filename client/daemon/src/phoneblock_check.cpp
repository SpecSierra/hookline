#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QSqlQuery>
#include <QTimer>
#include <QUrl>

#include "blocking.h"
#include "db.h"
#include "phoneblock_check.h"
#include "setting.h"

// Votes needed before a number counts as spam
static const int MIN_VOTES = 4;

phoneblock_check::phoneblock_check(QObject *parent) :
    QObject(parent)
{
}

// Contacts are never checked online
bool phoneblock_check::isContact(const QString &number) {
    QString digits = number;
    digits.remove(QRegExp("[^0-9]"));
    if (digits.length() < 8)
        return false;

    QSqlQuery query(db::Instance()->getContactsDb());
    query.prepare("SELECT 1 FROM PhoneNumbers WHERE substr(normalizedNumber, -8) = ? LIMIT 1");
    query.addBindValue(digits.right(8));
    return query.exec() && query.next();
}

void phoneblock_check::check(const phonenumber &number) {
    QString international = number.number_international;
    if (setting::get("phoneblock_check", "false") != "true"
            || !international.startsWith("+") || isContact(international))
        return;

    if (international == m_lastNumber && m_lastCheck.isValid() && m_lastCheck.elapsed() < 30000)
        return;
    m_lastNumber = international;
    m_lastCheck.start();

    QNetworkRequest request(QUrl("https://phoneblock.net/phoneblock/api/num/"
                                 + QUrl::toPercentEncoding(international) + "?format=json"));
    request.setRawHeader("User-Agent", "Hookline/1.0.0 (https://github.com/SpecSierra/hookline)");

    QNetworkReply *reply = m_net.get(request);
    // A late answer is useless: the call is over
    QTimer::singleShot(5000, reply, &QNetworkReply::abort);
    connect(reply, &QNetworkReply::finished, [this, reply, international]() { gotRating(reply, international); });
}

void phoneblock_check::gotRating(QNetworkReply *reply, QString number) {
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "phoneblock: check failed" << reply->errorString();
        return;
    }

    QJsonObject rating = QJsonDocument::fromJson(reply->readAll()).object();
    QString kind = rating.value("rating").toString();
    bool spam = !rating.value("whiteListed").toBool()
            && kind != "A_LEGITIMATE"
            && rating.value("votes").toInt() >= MIN_VOTES;
    qDebug() << "phoneblock:" << kind << rating.value("votes").toInt() << "votes";
    if (!spam)
        return;

    blocking::Instance()->hangup();

    QSqlQuery existing;
    existing.prepare("SELECT 1 FROM block WHERE number = ?");
    existing.addBindValue(number);
    if (existing.exec() && existing.next())
        return;

    QSqlQuery addRule;
    addRule.prepare("INSERT INTO block (type, name, number) VALUES (0, ?, ?)");
    addRule.addBindValue("PhoneBlock: spam");
    addRule.addBindValue(number);
    if (addRule.exec()) {
        QSqlQuery addHistory;
        addHistory.prepare("INSERT INTO block_history (block_id, number) VALUES (?, ?)");
        addHistory.addBindValue(addRule.lastInsertId());
        addHistory.addBindValue(number);
        addHistory.exec();
    }
}
