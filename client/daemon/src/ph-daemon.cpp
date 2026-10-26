#include <QCoreApplication>
#include <QDBusConnection>
#include <QDebug>
#include <QDir>

#include "block_lists.h"
#include "call_filter.h"
#include "db.h"
#include "dbus.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    db::Instance();

    QString dataDir = QDir::homePath() + "/.phonehook";
    QDir::home().mkpath(dataDir);

    block_lists lists(dataDir);
    call_filter filter(dataDir + "/phonehook.db", &lists);

    // incoming calls, network country
    dbus listener(&app);

    QDBusConnection::sessionBus().registerObject("/", &app);
    QDBusConnection::sessionBus().registerService("com.omnight.phonehook");

    return app.exec();
}
