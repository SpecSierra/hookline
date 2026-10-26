#ifndef SPAM_LISTS_H
#define SPAM_LISTS_H

#include <QNetworkAccessManager>
#include <QObject>
#include <QTimer>

class call_filter;

// Daily download of the French spam block lists published by Saracroche
// (https://saracroche.org, CC BY-NC-SA 4.0): the ARCEP telemarketing
// prefixes, the most reported operator ranges and the most reported numbers.
class spam_lists : public QObject
{
    Q_OBJECT

public:
    explicit spam_lists(QString cachePath, call_filter *filter, QObject *parent = 0);

    static QStringList filterEntries(QString pattern);

public slots:
    void check();

private:
    void download();
    void gotIndex(QNetworkReply *reply);
    void gotList(QNetworkReply *reply);

    QString m_cachePath;
    call_filter *m_filter;
    QNetworkAccessManager m_net;
    QTimer m_timer;
    int m_pending = 0;
    bool m_failed = false;
    int m_patterns = 0;
    QStringList m_entries;
};

#endif // SPAM_LISTS_H
