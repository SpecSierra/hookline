#ifndef CALL_FILTER_H
#define CALL_FILTER_H

#include <QFileSystemWatcher>
#include <QObject>
#include <QTimer>

// Keeps the reject list of the Sailfish OS 5 call filter (voicecall filter
// plugin) in sync with the block rules, so blocked calls are rejected before
// they ring. Rules the filter cannot express (a "*" that is not at the end)
// and older Sailfish OS releases are still handled by hanging up.
class call_filter : public QObject
{
    Q_OBJECT

public:
    call_filter(QString dbPath, QString spamListsPath, QObject *parent = 0);

public slots:
    void sync();

private:
    QStringList rejectedNumbers();

    QString m_spamListsPath;
    QFileSystemWatcher m_watcher;
    QTimer m_delay;
};

#endif // CALL_FILTER_H
