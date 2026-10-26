#ifndef DBUS_ADAPTER_H
#define DBUS_ADAPTER_H

#include <QDBusAbstractAdaptor>

// The GUI only checks that the service is registered
class dbus_adapter : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.omnight.phonehook")

private:
    static dbus_adapter *m_Instance;
    explicit dbus_adapter(QObject *parent = 0);

public:
    static dbus_adapter *Instance(QObject *parent = nullptr);

public Q_SLOTS:
    void Hello();
};

#endif // DBUS_ADAPTER_H
