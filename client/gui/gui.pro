# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = phonehook

CONFIG += sailfishapp c++14
SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256
QT += dbus xml sql xmlpatterns quick-private

INCLUDEPATH += ../common

SOURCES += \
    src/phonehook.cpp \
    src/bots.cpp \
    src/countries.cpp \
    src/blocks.cpp \
    src/calls.cpp \
    ../common/bot_download.cpp \
    ../common/setting.cpp \
    ../common/util.cpp

OTHER_FILES += qml/phonehook.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/phonehook.changes.in \
    rpm/phonehook.spec \
    rpm/phonehook.yaml \
    translations/*.ts \
    phonehook.desktop \
    qml/pages/PageServerBotList.qml \
    qml/pages/PageBotDetails.qml \
    qml/setting/SettingString.qml \
    qml/setting/SettingBool.qml \
    qml/pages/PageBotTest.qml \
    qml/pages/PageAppSettings.qml \
    qml/popup/gui.qml \
    qml/popup/images/ph-logo.png \
    qml/pages/PageBotDownload.qml \
    qml/pages/PageDownloadWait.qml \
    qml/setting/SettingPassword.qml \
    qml/popup/gui2.qml \
    qml/pages/PageSearchStart.qml \
    qml/pages/PageSearchResults.qml \
    qml/pages/PageBlockStart.qml \
    qml/pages/PageBlockContact.qml \
    qml/pages/PageBlockHistory.qml \
    qml/pages/PageCallLogStart.qml \
    qml/pages/PageBlockAddManual.qml \
    qml/pages/PageBlockAddSource.qml \
    qml/pages/PageSources.qml \
    qml/pages/StartItem.qml \
    qml/pages/PageAbout.qml \
    qml/pages/AboutLink.qml \
    qml/pages/SourceStatus.js \
    qml/pages/BlockLists.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/phonehook-es.ts \
                translations/phonehook-sv.ts \
                translations/phonehook-fi.ts \
                translations/phonehook-ru.ts \
                translations/phonehook-cs.ts \
                translations/phonehook-de.ts

HEADERS += \
    src/bots.h \
    src/countries.h \
    src/blocks.h \
    src/db_model.h \
    src/calls.h \
    ../common/setting.h \
    ../common/util.h \
    ../common/macros.h \
    ../common/bot_download.h

RESOURCES +=


