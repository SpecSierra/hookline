import QtQuick 2.5
import Sailfish.Silica 1.0
import "../setting"

Page {
    id: root

    property int botId: 0
    property variant botModel: null

    Component.onCompleted: {
        botModel = _bots.getBotDetails(botId)
        _bots.setActiveBot(botId)
        params.model = _bots.paramList
    }

    RemorsePopup {
        id: removeRemorse
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Report a problem")
                onClicked: Qt.openUrlExternally("https://github.com/SpecSierra/phonehook/issues")
            }
            MenuItem {
                text: qsTr("Remove")
                onClicked: removeRemorse.execute(qsTr("Removing %1").arg(botModel.name), function() {
                    _bots.removeBot(botId)
                    pageStack.pop()
                })
            }
            MenuItem {
                text: qsTr("Clear cache")
                onClicked: _bots.clearCache(botId)
            }
            MenuItem {
                text: qsTr("Test a number")
                onClicked: pageStack.push(Qt.resolvedUrl("PageBotTest.qml"), { name: botModel.name, botId: botModel.id })
            }
        }

        Column {
            id: contentColumn
            width: parent.width

            PageHeader {
                title: botModel ? botModel.name : ""
                description: botModel ? qsTr("Revision %1").arg(botModel.revision) : ""
            }

            SectionHeader {
                text: qsTr("Settings")
                visible: params.count > 0 || autoBlock.visible
            }

            Repeater {
                id: params

                delegate: Loader {
                    id: cpLoader
                    width: contentColumn.width

                    Component.onCompleted: {
                        if (model.type === "string") source = "../setting/SettingString.qml"
                        if (model.type === "password") source = "../setting/SettingPassword.qml"
                        if (model.type === "bool") source = "../setting/SettingBool.qml"
                    }

                    Connections {
                        ignoreUnknownSignals: true
                        target: cpLoader.item
                        onValueChanged: _bots.setBotParam(model.bot_id, model.key, value)
                    }
                }
            }

            TextSwitch {
                id: autoBlock
                visible: _bots.hasBlockTag(botId)
                text: qsTr("Block reported spam")
                description: qsTr("Reject numbers this source reports as spam")
                checked: _bots.isBlockSource(botId)
                onCheckedChanged: {
                    _bots.setBlockSource(botId, checked)
                    _blocks.initBlocks()
                }
            }

            SectionHeader {
                text: qsTr("About")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: botModel ? botModel.description : ""
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            BackgroundItem {
                visible: botModel && botModel.link !== ""
                height: linkLabel.height + 2 * Theme.paddingMedium
                onClicked: Qt.openUrlExternally(botModel.link)

                Label {
                    id: linkLabel
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * x
                    anchors.verticalCenter: parent.verticalCenter
                    text: botModel ? botModel.link : ""
                    font.pixelSize: Theme.fontSizeSmall
                    font.underline: true
                    color: parent.highlighted ? Theme.highlightColor : Theme.secondaryHighlightColor
                    wrapMode: Text.WrapAnywhere
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
