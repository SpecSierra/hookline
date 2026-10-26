import QtQuick 2.5
import Sailfish.Silica 1.0

// Calls blocked by one rule
Page {
    id: root

    property string title

    SilicaListView {
        id: historyView
        anchors.fill: parent
        model: _blocks.history

        header: PageHeader {
            title: root.title
            description: qsTr("Blocked calls")
        }

        ViewPlaceholder {
            enabled: historyView.count === 0
            text: qsTr("No blocked calls yet")
        }

        delegate: ListItem {
            id: historyItem
            contentHeight: Theme.itemSizeMedium

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Look up")
                    visible: model.number.length > 4
                    onClicked: _bots.testBot(0, model.number)
                }
                MenuItem {
                    text: qsTr("Copy number")
                    visible: model.number.length > 0
                    onClicked: Clipboard.text = model.number
                }
            }

            Column {
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    text: model.number || qsTr("Hidden number")
                    color: historyItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    width: parent.width
                    text: new Date(model.date).toLocaleString(Qt.locale(), Locale.ShortFormat)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: historyItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
