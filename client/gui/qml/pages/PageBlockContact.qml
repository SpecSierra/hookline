import QtQuick 2.5
import Sailfish.Silica 1.0

Page {
    id: root

    Component.onCompleted: _blocks.initContacts()

    SilicaListView {
        id: contactView
        anchors.fill: parent
        model: _blocks.contacts

        header: PageHeader {
            title: qsTr("Block contact")
        }

        ViewPlaceholder {
            enabled: contactView.count === 0
            text: qsTr("No contacts with a phone number")
        }

        delegate: ListItem {
            id: contactItem
            onClicked: {
                _blocks.addBlockedContact(model.contactId)
                pageStack.pop()
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                anchors.verticalCenter: parent.verticalCenter
                text: model.displayLabel
                truncationMode: TruncationMode.Fade
                color: contactItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

        VerticalScrollDecorator {}
    }
}
