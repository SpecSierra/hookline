import QtQuick 2.5
import Sailfish.Silica 1.0

Page {
    id: root

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("About")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: qsTr("Hookline looks up unknown callers and blocks unwanted calls before the phone rings.")
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Credits")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                textFormat: Text.StyledText
                text: qsTr("Hookline is based on <b>Phonehook</b>, created by <b>Johan Ekman (omnight)</b> in 2015 and maintained from 2019 by <b>Armin Felder</b>.")
                      + "<br>" + qsTr("Thanks to every contributor and translator of the original project.")
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            AboutLink {
                text: qsTr("Phonehook, the original project")
                url: "https://github.com/omnight/phonehook"
            }

            AboutLink {
                text: qsTr("Hookline source code")
                url: "https://github.com/SpecSierra/hookline"
            }

            SectionHeader {
                text: qsTr("Data")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: qsTr("French lists by Saracroche, licensed CC BY-NC-SA 4.0. Other countries: the number ranges their regulators reserve for telemarketing.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            AboutLink {
                text: "saracroche.org"
                url: "https://saracroche.org"
            }

            SectionHeader {
                text: qsTr("License")
            }

            AboutLink {
                text: qsTr("GNU General Public License v3")
                url: "https://www.gnu.org/licenses/gpl-3.0.html"
            }
        }

        VerticalScrollDecorator {}
    }
}
