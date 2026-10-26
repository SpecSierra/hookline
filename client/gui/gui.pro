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
QT += dbus sql

INCLUDEPATH += ../common

SOURCES += \
    src/phonehook.cpp \
    src/service.cpp \
    src/blocks.cpp \
    src/calls.cpp \
    ../common/setting.cpp \
    ../common/util.cpp

OTHER_FILES += qml/phonehook.qml \
    qml/cover/CoverPage.qml \
    qml/pages/*.qml \
    qml/pages/*.js \
    rpm/phonehook.changes.in \
    rpm/phonehook.spec \
    translations/*.ts \
    phonehook.desktop

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
    src/service.h \
    src/blocks.h \
    src/db_model.h \
    src/calls.h \
    ../common/setting.h \
    ../common/util.h \
    ../common/macros.h



