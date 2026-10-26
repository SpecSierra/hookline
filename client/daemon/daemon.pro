TARGET = phonehook-daemon
TEMPLATE = app

QT = core dbus sql network
CONFIG += c++14 link_pkgconfig
PKGCONFIG += mlite5

SOURCES += src/ph-daemon.cpp \
    src/dbus_adapter.cpp \
    src/dbus.cpp \
    src/db.cpp \
    src/phonenumber.cpp \
    src/blocking.cpp \
    src/call_filter.cpp \
    src/block_lists.cpp \
    ../common/util.cpp \
    ../common/setting.cpp

HEADERS += \
    src/call_filter.h \
    src/block_lists.h \
    src/dbus_adapter.h \
    src/dbus.h \
    src/db.h \
    src/phonenumber.h \
    src/blocking.h \
    ../common/macros.h \
    ../common/util.h \
    ../common/setting.h

INCLUDEPATH += ../common

# database upgrade scripts
RESOURCES += ph.qrc

target.path = /usr/bin
service.files = phonehook-daemon.service
service.path = /usr/lib/systemd/user
INSTALLS += target service
