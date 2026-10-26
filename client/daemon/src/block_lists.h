#ifndef BLOCK_LISTS_H
#define BLOCK_LISTS_H

#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QObject>
#include <QSet>
#include <QTimer>

// Number lists that are rejected before the phone rings, described by an
// index in phonehook-sources (blocklists/index.json): per list a name, a
// country, a licence and the files to download. Lists are downloaded daily;
// by default the lists of the home country are enabled ("block_list_<id>").
class block_lists : public QObject
{
    Q_OBJECT

public:
    explicit block_lists(QString cacheDir, QObject *parent = 0);

    // Call filter entries of the enabled lists
    QStringList entries();

    static QStringList filterEntries(QString pattern, QString countryCode, QString trunkPrefix);
    static bool isEnabled(const QJsonObject &list);

signals:
    void updated();

public slots:
    void check();

private:
    void download();
    void gotIndex(QNetworkReply *reply);
    void gotList(QNetworkReply *reply, QJsonObject list);
    void listDone(const QJsonObject &list);
    QString cachePath(const QJsonObject &list) const;
    QJsonArray index() const;

    QString m_cacheDir;
    QNetworkAccessManager m_net;
    QTimer m_timer;
    void roundDone();

    int m_pending = 0;
    bool m_roundFailed = false;
    // lists already fetched in this session, so a failing one isn't retried in a loop
    QSet<QString> m_attempted;
    // per list id: downloads left, failure, entries, patterns read
    QHash<QString, int> m_listPending;
    QHash<QString, bool> m_listFailed;
    QHash<QString, QStringList> m_listEntries;
    QHash<QString, int> m_listPatterns;
};

#endif // BLOCK_LISTS_H
