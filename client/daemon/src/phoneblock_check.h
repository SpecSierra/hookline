#ifndef PHONEBLOCK_CHECK_H
#define PHONEBLOCK_CHECK_H

#include <QElapsedTimer>
#include <QNetworkAccessManager>
#include <QObject>

#include "phonenumber.h"

// Optional check of unknown callers with PhoneBlock (https://phoneblock.net),
// a community spam list. Sends the incoming number; when the community rates
// it as spam the call is hung up and the number added to the user's rules,
// so its next call is rejected before the phone rings.
class phoneblock_check : public QObject
{
    Q_OBJECT

public:
    explicit phoneblock_check(QObject *parent = 0);

    void check(const phonenumber &number);

private:
    bool isContact(const QString &number);
    void gotRating(QNetworkReply *reply, QString number);

    QNetworkAccessManager m_net;
    // voicecall can report one call several times
    QString m_lastNumber;
    QElapsedTimer m_lastCheck;
};

#endif // PHONEBLOCK_CHECK_H
