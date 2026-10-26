import QtQuick 2.5
import Sailfish.Silica 1.0

Dialog {
    id: root

    property string number
    property string name

    acceptDestinationAction: PageStackAction.Pop
    canAccept: blockHidden.checked || (blockName.text != '' && blockNumber.text != '')

    onAccepted: _blocks.addManualBlock(blockName.text, blockNumber.text, blockHidden.checked)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            DialogHeader {
                acceptText: qsTr("Block")
                title: qsTr("Block number")
            }

            TextSwitch {
                id: blockHidden
                //: toggle switch for hidden number
                text: qsTr("Hidden numbers")
                description: qsTr("Calls without caller ID")
            }

            TextField {
                id: blockName
                width: parent.width
                visible: !blockHidden.checked
                //: placeholder for name input
                label: qsTr("Name")
                placeholderText: label
                text: name
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: blockNumber.focus = true
            }

            TextField {
                id: blockNumber
                width: parent.width
                visible: !blockHidden.checked
                //: placeholder for number input
                label: qsTr("Phone number")
                placeholderText: label
                text: number
                inputMethodHints: Qt.ImhDialableCharactersOnly
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: !blockHidden.checked
                text: qsTr("Local or international format. End with * to block every number starting with it, for example 0899*.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
            }
        }

        VerticalScrollDecorator {}
    }
}
