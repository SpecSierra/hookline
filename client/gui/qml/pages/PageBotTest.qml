import QtQuick 2.5
import Sailfish.Silica 1.0

// Runs a lookup like an incoming call would; the result shows in the call popup
Page {
    id: root

    property string name
    property int botId

    function run() {
        if (testNumber.text.length > 0)
            _bots.testBot(botId, testNumber.text)
    }

    Column {
        width: parent.width

        PageHeader {
            title: name
            description: botId === 0 ? qsTr("All lookup sources") : ""
        }

        TextField {
            id: testNumber
            width: parent.width
            label: qsTr("Phone number")
            placeholderText: label
            inputMethodHints: Qt.ImhDialableCharactersOnly
            focus: true
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-search"
            EnterKey.onClicked: root.run()
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Look up")
            enabled: testNumber.text.length > 0
            onClicked: root.run()
        }

        Item {
            width: parent.width
            height: Theme.paddingLarge
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            text: qsTr("The result is shown in the same popup as during a call.")
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryHighlightColor
            wrapMode: Text.Wrap
        }
    }
}
