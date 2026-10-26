import QtQuick 2.5
import Sailfish.Silica 1.0
import "BlockLists.js" as BlockLists

// Number lists downloaded daily and rejected before the phone rings
Page {
    id: root

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Block lists")
                description: qsTr("Updated daily, on by default for your country")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: listRepeater.count === 0
                text: _service.daemonActive
                      ? qsTr("The block lists are downloaded by the service. Check the network connection.")
                      : qsTr("Start the service to download the block lists.")
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
            }

            Repeater {
                id: listRepeater
                model: BlockLists.index(_setting)

                Column {
                    width: column.width

                    TextSwitch {
                        text: modelData.name
                        description: modelData.description
                        checked: BlockLists.isEnabled(_setting, modelData)
                        onCheckedChanged: _setting.put("block_list_" + modelData.id, checked)
                    }

                    Label {
                        x: Theme.horizontalPageMargin + Theme.itemSizeExtraSmall
                        width: parent.width - x - Theme.horizontalPageMargin
                        text: BlockLists.summary(_setting, modelData)
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        wrapMode: Text.Wrap
                    }

                    BackgroundItem {
                        visible: modelData.attribution !== undefined
                        height: attribution.height + 2 * Theme.paddingSmall
                        onClicked: Qt.openUrlExternally(modelData.attribution_url)

                        Label {
                            id: attribution
                            x: Theme.horizontalPageMargin + Theme.itemSizeExtraSmall
                            width: parent.width - x - Theme.horizontalPageMargin
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Source: %1, %2").arg(modelData.attribution).arg(modelData.license)
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.underline: true
                            color: parent.highlighted ? Theme.highlightColor : Theme.secondaryColor
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Online check")
            }

            TextSwitch {
                text: qsTr("Check unknown callers with PhoneBlock")
                description: qsTr("The number of each incoming call that is not a contact is sent to phoneblock.net. Numbers its community reports as spam are hung up and added to your rules.")
                checked: _setting.get("phoneblock_check", "false") === "true"
                onCheckedChanged: _setting.put("phoneblock_check", checked)
            }

            AboutLink {
                text: "phoneblock.net"
                url: "https://phoneblock.net"
            }
        }

        VerticalScrollDecorator {}
    }
}
