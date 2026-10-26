import QtQuick 2.5
import Sailfish.Silica 1.0

Page {
    id: apps

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + Theme.paddingLarge

        Column {
            id: contentColumn
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            TextSwitch {
                text: qsTr("Close the dialer when blocking")
                description: qsTr("Only used when a call has to be hung up instead of being rejected before ringing, for example hidden numbers")
                checked: _setting.get("kill_voicecall_ui", "false") === "true"
                onCheckedChanged: _setting.put("kill_voicecall_ui", checked)
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Restart service")
                onClicked: _service.startDaemon()
            }
        }

        VerticalScrollDecorator {}
    }
}
