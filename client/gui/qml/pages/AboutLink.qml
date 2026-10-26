import QtQuick 2.5
import Sailfish.Silica 1.0

// A tappable line that opens a web page
BackgroundItem {
    property alias text: label.text
    property string url

    width: parent.width
    height: Theme.itemSizeSmall
    onClicked: Qt.openUrlExternally(url)

    Label {
        id: label
        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        anchors.verticalCenter: parent.verticalCenter
        truncationMode: TruncationMode.Fade
        font.underline: true
        color: parent.highlighted ? Theme.highlightColor : Theme.secondaryHighlightColor
    }
}
