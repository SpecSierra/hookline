#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDir>
#include <QProcess>
#include <QSqlQuery>

#include "service.h"

static const char *SERVICE_NAME = "com.omnight.phonehook";

service::service(QObject *parent) :
    QObject(parent)
{
    QString dataDir = QDir::homePath() + "/.phonehook";
    QDir::home().mkpath(dataDir);

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dataDir + "/phonehook.db");
    m_db.open();
    m_db.exec("PRAGMA foreign_keys = ON;");

    m_watcher.setConnection(QDBusConnection::sessionBus());
    m_watcher.addWatchedService(SERVICE_NAME);
    connect(&m_watcher, &QDBusServiceWatcher::serviceRegistered, [this]() { setDaemonActive(true); });
    connect(&m_watcher, &QDBusServiceWatcher::serviceUnregistered, [this]() { setDaemonActive(false); });

    m_daemonActive = QDBusConnection::sessionBus().interface()->isServiceRegistered(SERVICE_NAME);
    if (!m_daemonActive)
        startDaemon();
}

service::~service() {
    m_db.close();
}

void service::startDaemon() {
    QProcess::startDetached("systemctl", QStringList() << "--user" << "restart" << "phonehook-daemon.service");
}

void service::setDaemonActive(bool active) {
    if (active == m_daemonActive)
        return;
    m_daemonActive = active;
    emit daemonActiveChanged(active);
}
