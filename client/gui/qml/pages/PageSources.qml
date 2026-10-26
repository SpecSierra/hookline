import QtQuick 2.5
import Sailfish.Silica 1.0
import "SourceStatus.js" as SourceStatus
import "BlockLists.js" as BlockLists

// Where caller information and block lists come from
Page {
    id: root

    // Source name -> { status, status_note } from the source index
    property var sourceStatus: ({})

    Component.onCompleted: {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            try {
                var statuses = {}
                var sources = JSON.parse(xhr.responseText)
                for (var i = 0; i < sources.length; i++)
                    statuses[sources[i].name] = { status: sources[i].status, note: sources[i].status_note }
                sourceStatus = statuses
            } catch (e) {
                console.log("source index:", e)
            }
        }
        xhr.open("GET", _setting.get("sources_index_url", "https://raw.githubusercontent.com/SpecSierra/phonehook-sources/master/files/index.js"))
        xhr.send()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Add lookup source")
                enabled: _bots.daemonActive
                onClicked: pageStack.push(Qt.resolvedUrl("PageServerBotList.qml"))
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Data sources")
            }

            SectionHeader {
                text: qsTr("Block lists")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: listRepeater.count === 0
                text: qsTr("The list of block lists is downloaded by the service.")
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
                text: qsTr("Lookup sources")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: sourceRepeater.count === 0
                text: _bots.daemonActive
                      ? qsTr("No lookup sources yet. Pull down to add one for your country.")
                      : qsTr("Start the service to manage lookup sources.")
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
            }

            Repeater {
                id: sourceRepeater
                model: _bots.daemonActive ? _bots.botList : []

                ListItem {
                    id: sourceItem
                    contentHeight: Theme.itemSizeMedium
                    onClicked: pageStack.push(Qt.resolvedUrl("PageBotDetails.qml"), { botId: model.id })

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: sourceItem.remorseDelete(function() { _bots.removeBot(model.id) })
                        }
                    }

                    Icon {
                        id: sourceIcon
                        x: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-website"
                    }

                    Column {
                        anchors {
                            left: sourceIcon.right; leftMargin: Theme.paddingLarge
                            right: parent.right; rightMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                        }
                        Label {
                            width: parent.width
                            text: model.name
                            truncationMode: TruncationMode.Fade
                            color: sourceItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        }
                        Label {
                            property var known: sourceStatus[model.name] || {}
                            width: parent.width
                            text: {
                                var works = SourceStatus.text(known.status, known.note)
                                return qsTr("Revision %1").arg(model.revision) + (works !== "" ? " · " + works : "")
                            }
                            truncationMode: TruncationMode.Fade
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: SourceStatus.isProblem(known.status) ? Theme.errorColor
                                 : sourceItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
