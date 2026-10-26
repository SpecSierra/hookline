import QtQuick 2.5
import Sailfish.Silica 1.0

Dialog {
    id: root

    property variant botData

    // 0 not installed, 1 up to date, 2 update available, 3 needs a newer Hookline
    property int status: {
        if (botData.minversion && botData.minversion > _bots.version())
            return 3
        return _bots.botStatusCompare(botData.name, botData.revision)
    }

    canAccept: status !== 3

    onAccepted: {
        pageStack.replace(Qt.resolvedUrl("PageDownloadWait.qml"))
        _bots.downloadBot(botData.file, true)
    }

    function capabilityName(s) {
        switch (s) {
        case 'lookup': return qsTr('Reverse caller lookup')
        case 'person_search': return qsTr('Search for people')
        case 'business_search': return qsTr('Search for businesses')
        case 'block': return qsTr('Reports spam numbers')
        }
        return s
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            DialogHeader {
                acceptText: status === 1 ? qsTr("Reinstall")
                          : status === 2 ? qsTr("Update")
                          : status === 3 ? "" : qsTr("Install")
                title: botData.name
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: status === 1 ? qsTr("Installed and up to date")
                    : status === 2 ? qsTr("Update available")
                    : status === 3 ? qsTr("Needs a newer version of Hookline")
                                   : qsTr("Not installed")
                color: status === 3 ? Theme.errorColor : Theme.highlightColor
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Capabilities")
                visible: botData.tags.count > 0
            }

            Repeater {
                model: botData.tags
                Label {
                    x: Theme.horizontalPageMargin
                    width: column.width - 2 * x
                    text: "• " + capabilityName(model.cap)
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }
            }

            SectionHeader {
                text: qsTr("About")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: botData.description
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            BackgroundItem {
                visible: botData.link !== ""
                height: linkLabel.height + 2 * Theme.paddingMedium
                onClicked: Qt.openUrlExternally(botData.link)

                Label {
                    id: linkLabel
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * x
                    anchors.verticalCenter: parent.verticalCenter
                    text: botData.link
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
