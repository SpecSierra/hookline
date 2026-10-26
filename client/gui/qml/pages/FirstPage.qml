import QtQuick 2.5
import Sailfish.Silica 1.0
import "BlockLists.js" as BlockLists

Page {
    id: topPage

    function refresh() {
        _blocks.initBlocks()
    }

    onStatusChanged: if (status === PageStatus.Active) refresh()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("PageAbout.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("PageAppSettings.qml"))
            }
            MenuItem {
                text: qsTr("Look up a number")
                enabled: _bots.daemonActive
                onClicked: pageStack.push(Qt.resolvedUrl("PageBotTest.qml"), { name: qsTr("Look up a number"), botId: 0 })
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "Hookline"
                description: qsTr("Caller lookup and call blocking")
            }

            // Everything depends on the daemon: make a stopped one obvious
            ListItem {
                id: daemonItem
                contentHeight: Theme.itemSizeMedium
                visible: !_bots.daemonActive
                onClicked: _bots.startDaemon()

                Icon {
                    id: warningIcon
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-warning"
                    color: Theme.errorColor
                }
                Column {
                    anchors {
                        left: warningIcon.right; leftMargin: Theme.paddingMedium
                        right: parent.right; rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    Label {
                        width: parent.width
                        text: qsTr("Service not running")
                        color: Theme.errorColor
                    }
                    Label {
                        width: parent.width
                        text: qsTr("Tap to start it. Calls are neither looked up nor blocked.")
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        wrapMode: Text.Wrap
                    }
                }
            }

            StartItem {
                icon: "image://theme/icon-m-device-lock"
                title: qsTr("Blocking")
                description: _blocks.db_blocks.count === 0
                             ? qsTr("No rules")
                             : qsTr("%n rule(s)", "", _blocks.db_blocks.count)
                page: "PageBlockStart.qml"
            }

            StartItem {
                icon: "image://theme/icon-m-cloud-download"
                title: qsTr("Data sources")
                description: {
                    var lookups = _bots.daemonActive ? _bots.botList.count : 0
                    var lists = BlockLists.index(_setting).filter(function(list) {
                        return BlockLists.isEnabled(_setting, list)
                    }).length
                    return qsTr("%n lookup source(s)", "", lookups)
                            + " · " + qsTr("%n block list(s)", "", lists)
                }
                page: "PageSources.qml"
            }

            StartItem {
                icon: "image://theme/icon-m-history"
                title: qsTr("Call log")
                description: qsTr("Look up or block recent callers")
                page: "PageCallLogStart.qml"
            }

            StartItem {
                icon: "image://theme/icon-m-search"
                title: qsTr("Search")
                description: qsTr("Find people and businesses")
                page: "PageSearchStart.qml"
                enabled: _bots.daemonActive
            }
        }

        VerticalScrollDecorator {}
    }
}
