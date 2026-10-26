import QtQuick 2.5
import Sailfish.Silica 1.0
import "SourceStatus.js" as SourceStatus

// Lookup sources that can be installed, grouped by country (own country first)
Page {
    id: root

    property bool loading: true
    property bool failed: false

    // Installation state (0 not installed, 1 installed, 2 update available)
    // and how well the source works
    function statusText(source) {
        var installed = _bots.botStatusCompare(source.name, source.revision)
        var parts = []
        if (installed === 2) parts.push(qsTr("Update available"))
        if (installed === 1) parts.push(qsTr("Installed"))
        var works = SourceStatus.text(source.status, source.status_note)
        if (works !== "") parts.push(works)
        return parts.join(" · ")
    }

    Component.onCompleted: {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            loading = false
            var sources
            try {
                sources = JSON.parse(xhr.responseText)
            } catch (e) {
                failed = true
                return
            }

            var myCountry = _setting.get("location", "").toUpperCase()
            sources.sort(function(a, b) {
                var mineA = a.country === myCountry ? 0 : 1
                var mineB = b.country === myCountry ? 0 : 1
                if (mineA !== mineB) return mineA - mineB
                return a.sort_key < b.sort_key ? -1 : a.sort_key > b.sort_key ? 1 : 0
            })

            for (var i = 0; i < sources.length; i++) {
                var tags = []
                for (var t = 0; t < sources[i].tags.length; t++)
                    tags.push({ "cap": sources[i].tags[t] })
                sources[i].tags = tags
                // ListModel takes its roles from the first entry: always set them
                sources[i].status = sources[i].status || ""
                sources[i].status_note = sources[i].status_note || ""
                sources[i].countryName = sources[i].country === "_ALL"
                        ? qsTr("All countries") : _bots.getCountryName(sources[i].country)
                serverBots.append(sources[i])
            }
        }
        xhr.open("GET", _setting.get("sources_index_url", "https://raw.githubusercontent.com/SpecSierra/phonehook-sources/master/files/index.js"))
        xhr.send()
    }

    ListModel {
        id: serverBots
    }

    SilicaListView {
        id: botListView
        anchors.fill: parent
        model: serverBots

        header: PageHeader {
            title: qsTr("Add lookup source")
        }

        section.property: "countryName"
        section.delegate: SectionHeader {
            text: section
        }

        BusyIndicator {
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: loading
        }

        ViewPlaceholder {
            enabled: failed
            text: qsTr("Could not load the list of sources")
        }

        delegate: ListItem {
            id: sourceItem
            contentHeight: Theme.itemSizeMedium
            onClicked: pageStack.push(Qt.resolvedUrl("PageBotDownload.qml"), { botData: model })

            Column {
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
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
                    id: statusLabel
                    width: parent.width
                    text: statusText(model)
                    visible: text !== ""
                    font.pixelSize: Theme.fontSizeExtraSmall
                    truncationMode: TruncationMode.Fade
                    color: SourceStatus.isProblem(model.status) ? Theme.errorColor
                         : sourceItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor

                    Connections {
                        target: _bots.botList
                        ignoreUnknownSignals: true
                        onCount_changed: statusLabel.text = statusText(model)
                    }
                }
            }
        }

        footer: Label {
            x: Theme.horizontalPageMargin
            width: botListView.width - 2 * x
            height: implicitHeight + 2 * Theme.paddingLarge
            verticalAlignment: Text.AlignVCenter
            visible: serverBots.count > 0
            text: qsTr("All names and logos listed here are properties of respective rights holders. Phonehook is not endorsed by any of these services.")
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            wrapMode: Text.Wrap
        }

        VerticalScrollDecorator {}
    }
}
