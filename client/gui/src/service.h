#ifndef SERVICE_H
#define SERVICE_H

#include <QDBusServiceWatcher>
#include <QObject>
#include <QSqlDatabase>

// Opens the database shared with the daemon and tells whether the daemon
// (which does the blocking) is running
class service : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool daemonActive READ daemonActive NOTIFY daemonActiveChanged)

public:
    explicit service(QObject *parent = 0);
    ~service();

    bool daemonActive() const { return m_daemonActive; }

    Q_INVOKABLE void startDaemon();

signals:
    void daemonActiveChanged(bool active);

private:
    void setDaemonActive(bool active);

    QSqlDatabase m_db;
    QDBusServiceWatcher m_watcher;
    bool m_daemonActive;
};

#endif // SERVICE_H
