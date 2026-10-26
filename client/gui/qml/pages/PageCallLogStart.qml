import QtQuick 2.5
import Sailfish.Silica 1.0

Page {
    id: root

    SilicaListView {
        id: callView
        anchors.fill: parent
        model: _calls.call_log

        header: PageHeader {
            title: qsTr("Call log")
            description: _calls.filter == "incoming" ? qsTr("Incoming calls")
                       : _calls.filter == "outgoing" ? qsTr("Outgoing calls")
                                                     : qsTr("Missed calls")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Outgoing calls")
                onClicked: _calls.filter = "outgoing"
            }
            MenuItem {
                text: qsTr("Incoming calls")
                onClicked: _calls.filter = "incoming"
            }
            MenuItem {
                text: qsTr("Missed calls")
                onClicked: _calls.filter = "missed"
            }
        }

        ViewPlaceholder {
            enabled: callView.count === 0
            text: qsTr("No calls")
        }

        delegate: ListItem {
            id: callItem

            property string number: model.remoteUid
            property string name: _blocks.contactNameFromNumber(model.remoteUid)

            contentHeight: Theme.itemSizeMedium
            onClicked: pageStack.push(Qt.resolvedUrl("PageBlockAddManual.qml"),
                                      { name: callItem.name, number: callItem.number })

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Copy number")
                    onClicked: Clipboard.text = callItem.number
                }
            }

            Icon {
                id: callIcon
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                source: _calls.filter == "incoming" ? "image://theme/icon-m-incoming-call"
                      : _calls.filter == "outgoing" ? "image://theme/icon-m-outgoing-call"
                                                    : "image://theme/icon-m-missed-call"
            }

            Column {
                anchors {
                    left: callIcon.right; leftMargin: Theme.paddingLarge
                    right: countLabel.left; rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    text: callItem.name || callItem.number
                    truncationMode: TruncationMode.Fade
                    color: callItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    width: parent.width
                    text: new Date(model.recent_time * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: callItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }

            Label {
                id: countLabel
                anchors {
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                // number of calls from this number
                text: model.call_count > 1 ? model.call_count : ""
                color: callItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        VerticalScrollDecorator {}
    }
}
