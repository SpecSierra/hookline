import QtQuick 2.5
import Sailfish.Silica 1.0

Page {
    id: root

    onStatusChanged: if (status === PageStatus.Active) _blocks.initBlocks()

    SilicaListView {
        id: blockView
        anchors.fill: parent
        model: _blocks.db_blocks

        header: PageHeader {
            title: qsTr("Blocking")
            description: qsTr("Matching calls are rejected before the phone rings")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Block lookup source results")
                onClicked: {
                    _blocks.initSources()
                    pageStack.push(Qt.resolvedUrl("PageBlockAddSource.qml"))
                }
            }
            MenuItem {
                text: qsTr("Block contact")
                onClicked: pageStack.push(Qt.resolvedUrl("PageBlockContact.qml"))
            }
            MenuItem {
                text: qsTr("Block number")
                onClicked: pageStack.push(Qt.resolvedUrl("PageBlockAddManual.qml"))
            }
        }

        ViewPlaceholder {
            enabled: blockView.count === 0
            text: qsTr("No blocking rules")
            hintText: qsTr("Pull down to block a number, a contact or the spam numbers found by a lookup source")
        }

        delegate: ListItem {
            id: blockItem

            property string name: model.name || model.bot_name
                                  || (model.contact_id ? _blocks.contactName(model.contact_id) : "?")

            contentHeight: Theme.itemSizeMedium
            onClicked: {
                _blocks.initHistory(model.id)
                pageStack.push(Qt.resolvedUrl("PageBlockHistory.qml"), { title: blockItem.name })
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Edit")
                    visible: model.type === 0
                    onClicked: pageStack.push(Qt.resolvedUrl("PageBlockEdit.qml"),
                                              { "contact_id": model.id,
                                                "contact_name": blockItem.name,
                                                "contact_nbr": model.number })
                }
                MenuItem {
                    text: qsTr("Delete")
                    onClicked: blockItem.remorseDelete(function() {
                        _blocks.deleteBlock(model.id)
                        _blocks.initBlocks()
                    })
                }
            }

            Icon {
                id: typeIcon
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                source: model.type === 1 ? "image://theme/icon-m-contact"
                      : model.type === 2 ? "image://theme/icon-m-website"
                                         : "image://theme/icon-m-dialpad"
            }

            Column {
                anchors {
                    left: typeIcon.right; leftMargin: Theme.paddingLarge
                    right: countLabel.left; rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    text: blockItem.name
                    truncationMode: TruncationMode.Fade
                    color: blockItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    width: parent.width
                    visible: text !== ""
                    text: model.type === 0 ? (model.number || qsTr("Hidden numbers"))
                        : model.type === 1 ? qsTr("Contact")
                                           : qsTr("Spam found by this lookup source")
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: blockItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }

            Label {
                id: countLabel
                anchors {
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                // calls blocked by this rule
                text: model.block_count > 0 ? model.block_count : ""
                color: blockItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        VerticalScrollDecorator {}
    }
}
