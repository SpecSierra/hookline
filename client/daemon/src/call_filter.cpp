#include <QDebug>
#include <QSqlQuery>
#include <MDConfItem>

#include "block_lists.h"
#include "call_filter.h"
#include "db.h"
#include "setting.h"

call_filter::call_filter(QString dbPath, block_lists *lists, QObject *parent) :
    QObject(parent), m_lists(lists)
{
    connect(lists, &block_lists::updated, this, &call_filter::sync);

    // The GUI edits the block rules directly in the database
    m_delay.setSingleShot(true);
    m_delay.setInterval(1000);
    connect(&m_delay, &QTimer::timeout, this, &call_filter::sync);
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, [this, dbPath]() {
        if (!m_watcher.files().contains(dbPath))
            m_watcher.addPath(dbPath);
        m_delay.start();
    });
    m_watcher.addPath(dbPath);

    sync();
}

// Filter entries: exact numbers, or "^" followed by a number prefix
static QString filterEntry(QString number) {
    number.remove(QRegExp("[\\s()./-]"));

    QString entry = number;
    if (number.indexOf('*') == number.length() - 1)
        entry = "^" + number.left(number.length() - 1);

    if (!entry.contains(QRegExp("^\\^?\\+?\\d+$")))
        return "";
    return entry;
}

QStringList call_filter::rejectedNumbers() {
    QStringList numbers;

    QSqlQuery manual("SELECT number FROM block WHERE type=0");
    while (manual.next())
        numbers << filterEntry(manual.value(0).toString());

    QStringList contactIds;
    QSqlQuery contacts("SELECT contact_id FROM block WHERE type=1");
    while (contacts.next())
        contactIds << QString::number(contacts.value(0).toInt());

    if (contactIds.count() > 0) {
        QSqlQuery contactNumbers("SELECT phoneNumber FROM PhoneNumbers WHERE contactId IN ("
                                 + contactIds.join(",") + ")", db::Instance()->getContactsDb());
        while (contactNumbers.next())
            numbers << filterEntry(contactNumbers.value(0).toString());
    }

    // Enabled block lists, already in filter format
    numbers << m_lists->entries();

    numbers.removeAll("");
    numbers.removeDuplicates();
    return numbers;
}

void call_filter::sync() {
    // Only replace the entries phonehook added, keep the user's own
    MDConfItem rejected("/sailfish/voicecall/filter/rejected-numbers");
    QStringList current = rejected.value().toStringList();
    QStringList added = setting::get("call_filter_rejected", "").split("\n", QString::SkipEmptyParts);
    QStringList wanted = rejectedNumbers();

    QStringList updated = current;
    for (const QString &entry : added)
        updated.removeAll(entry);
    for (const QString &entry : wanted)
        if (!updated.contains(entry))
            updated.append(entry);

    if (updated != current) {
        qDebug() << "call filter: rejecting" << wanted.count() << "numbers";
        rejected.set(updated);
    }
    setting::put("call_filter_rejected", wanted.join("\n"));
}
