#include <QDebug>
#include <QFile>
#include <QSqlQuery>
#include <MDConfItem>

#include "call_filter.h"
#include "db.h"
#include "setting.h"

call_filter::call_filter(QString dbPath, QString spamListsPath, QObject *parent) :
    QObject(parent), m_spamListsPath(spamListsPath)
{
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

    // Numbers that the auto-blocking sources have already flagged
    QSqlQuery autoBlocked(R"(
        SELECT DISTINCT bot_result_cache.telnr FROM block
        JOIN bot_result_cache ON block.bot_id = bot_result_cache.bot_id
        WHERE bot_result_cache.block = 1
    )");
    while (autoBlocked.next())
        numbers << filterEntry(autoBlocked.value(0).toString());

    // Downloaded spam lists, already in filter format (see spam_lists)
    QFile spamLists(m_spamListsPath);
    if (setting::get("spam_lists", "true") == "true" && spamLists.open(QIODevice::ReadOnly))
        numbers << QString::fromUtf8(spamLists.readAll()).split("\n");

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
