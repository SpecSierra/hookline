#include <QtQuick>
#include <sailfishapp.h>

#include "blocks.h"
#include "calls.h"
#include "db_model.h"
#include "service.h"
#include "setting.h"

int main(int argc, char *argv[])
{
    QGuiApplication* app = SailfishApp::application(argc, argv);

    // opens the database, so it comes first
    service daemonService;
    blocks blocks;
    calls calls;

    QQuickView* view = SailfishApp::createView();

    view->rootContext()->setContextProperty("_service", &daemonService);
    view->rootContext()->setContextProperty("_blocks", &blocks);
    view->rootContext()->setContextProperty("_calls", &calls);
    view->rootContext()->setContextProperty("_setting", setting::Instance());

    view->setSource(SailfishApp::pathTo("qml/phonehook.qml"));
    view->showFullScreen();

    return app->exec();
}
