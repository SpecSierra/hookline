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

            SectionHeader {
                text: qsTr("Incoming calls")
            }

            TextSwitch {
                text: qsTr("Show only for unknown contacts")
                checked: _setting.get("activate_only_unknown", "true") === "true"
                onCheckedChanged: _setting.put("activate_only_unknown", checked)
            }

            TextSwitch {
                text: qsTr("Enable while roaming")
                checked: _setting.get("enable_roaming", "false") === "true"
                onCheckedChanged: _setting.put("enable_roaming", checked)
            }

            TextSwitch {
                text: qsTr("Old popup design")
                checked: _setting.get("old_popup_design", "false") === "true"
                onCheckedChanged: _setting.put("old_popup_design", checked)
            }

            Slider {
                width: parent.width
                label: qsTr("Popup timeout")
                value: _setting.get("popup_timeout", "0")
                valueText: value == 0 ? qsTr("Disabled") : qsTr("%1 s").arg(value)
                stepSize: 10
                maximumValue: 120
                onValueChanged: _setting.put("popup_timeout", value)
            }

            SectionHeader {
                text: qsTr("Data sources")
            }

            TextSwitch {
                text: qsTr("Update lookup sources automatically")
                checked: _setting.get("auto_update_enabled", "true") === "true"
                onCheckedChanged: _setting.put("auto_update_enabled", checked)
            }

            SectionHeader {
                text: qsTr("Advanced")
            }

            TextSwitch {
                text: qsTr("Source test mode")
                description: qsTr("Use the beta channel of the lookup sources")
                checked: _setting.get("download_root_url", "") !== ""
                onCheckedChanged: {
                    if (checked) {
                        _setting.put("download_root_url", "https://raw.githubusercontent.com/omnight/phonehook-sources/beta/files/")
                        _setting.put("auto_update_index_url", "https://raw.githubusercontent.com/omnight/phonehook-sources/beta/files/i.js")
                        _setting.put("sources_index_url", "https://raw.githubusercontent.com/omnight/phonehook-sources/beta/files/index.js")
                    } else {
                        // use default values
                        _setting.remove("download_root_url")
                        _setting.remove("auto_update_index_url")
                        _setting.remove("sources_index_url")
                    }
                }
            }

            TextSwitch {
                text: qsTr("Close the dialer when blocking")
                description: qsTr("Only used when a call has to be hung up instead of being rejected before ringing")
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
                onClicked: _bots.startDaemon()
            }
        }

        VerticalScrollDecorator {}
    }
}
