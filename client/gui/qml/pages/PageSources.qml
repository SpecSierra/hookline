import QtQuick 2.5
import Sailfish.Silica 1.0
import "SourceStatus.js" as SourceStatus

// Where caller information and block lists come from
Page {
    id: root

    // Source name -> { status, status_note } from the source index
    property var sourceStatus: ({})

    Component.onCompleted: {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            try {
                var statuses = {}
                var sources = JSON.parse(xhr.responseText)
                for (var i = 0; i < sources.length; i++)
                    statuses[sources[i].name] = { status: sources[i].status, note: sources[i].status_note }
                sourceStatus = statuses
            } catch (e) {
                console.log("source index:", e)
            }
        }
        xhr.open("GET", _setting.get("sources_index_url", "https://raw.githubusercontent.com/SpecSierra/phonehook-sources/master/files/index.js"))
        xhr.send()
    }

    function listsSummary() {
        var count = parseInt(_setting.get("spam_lists_count", "0"))
        var updated = _setting.get("spam_lists_updated", "")
        if (updated === "")
            return qsTr("Not downloaded yet")
        var date = new Date(updated).toLocaleString(Qt.locale(), Locale.ShortFormat)
        return qsTr("%n entries", "", count) + " · " + qsTr("updated %1").arg(date)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Add lookup source")
                enabled: _bots.daemonActive
                onClicked: pageStack.push(Qt.resolvedUrl("PageServerBotList.qml"))
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Data sources")
            }

            SectionHeader {
                text: qsTr("Block lists")
            }

            TextSwitch {
                text: qsTr("French spam calls")
                description: qsTr("Telemarketing prefixes (ARCEP) and the most reported numbers, rejected before the phone rings. Updated daily.")
                checked: _setting.get("spam_lists", "true") === "true"
                onCheckedChanged: _setting.put("spam_lists", checked)
            }

            Label {
                x: Theme.horizontalPageMargin + Theme.itemSizeExtraSmall
                width: parent.width - x - Theme.horizontalPageMargin
                text: listsSummary()
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
            }

            BackgroundItem {
                height: attribution.height + 2 * Theme.paddingSmall
                onClicked: Qt.openUrlExternally("https://saracroche.org")

                Label {
                    id: attribution
                    x: Theme.horizontalPageMargin + Theme.itemSizeExtraSmall
                    width: parent.width - x - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Lists by Saracroche (saracroche.org), CC BY-NC-SA 4.0")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.underline: true
                    color: parent.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    wrapMode: Text.Wrap
                }
            }

            SectionHeader {
                text: qsTr("Lookup sources")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: sourceRepeater.count === 0
                text: _bots.daemonActive
                      ? qsTr("No lookup sources yet. Pull down to add one for your country.")
                      : qsTr("Start the service to manage lookup sources.")
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
            }

            Repeater {
                id: sourceRepeater
                model: _bots.daemonActive ? _bots.botList : []

                ListItem {
                    id: sourceItem
                    contentHeight: Theme.itemSizeMedium
                    onClicked: pageStack.push(Qt.resolvedUrl("PageBotDetails.qml"), { botId: model.id })

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: sourceItem.remorseDelete(function() { _bots.removeBot(model.id) })
                        }
                    }

                    Icon {
                        id: sourceIcon
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-website"
                    }

                    Column {
                        anchors {
                            left: sourceIcon.right; leftMargin: Theme.paddingLarge
                            right: parent.right; rightMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                        }
                        Label {
                            width: parent.width
                            text: model.name
                            truncationMode: TruncationMode.Fade
                            color: sourceItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            property var known: sourceStatus[model.name] || {}
                            width: parent.width
                            text: {
                                var works = SourceStatus.text(known.status, known.note)
                                return qsTr("Revision %1").arg(model.revision) + (works !== "" ? " · " + works : "")
                            }
                            truncationMode: TruncationMode.Fade
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: SourceStatus.isProblem(known.status) ? Theme.errorColor
                                 : sourceItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
