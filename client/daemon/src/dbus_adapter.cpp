#include <QDebug>

#include "dbus_adapter.h"

dbus_adapter *dbus_adapter::m_Instance = nullptr;

dbus_adapter::dbus_adapter(QObject *parent) :
    QDBusAbstractAdaptor(parent)
{
}

dbus_adapter* dbus_adapter::Instance(QObject *parent) {
    if(m_Instance == nullptr)
        m_Instance = new dbus_adapter(parent);

    return m_Instance;
}

void dbus_adapter::Hello() {
    qDebug() << "hello";
}
