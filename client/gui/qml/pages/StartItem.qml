import QtQuick 2.5
import Sailfish.Silica 1.0

// A row of the start page: icon, title, one-line summary, opens a page
ListItem {
    id: item

    property alias icon: image.source
    property alias title: titleLabel.text
    property alias description: descriptionLabel.text
    property string page

    contentHeight: Theme.itemSizeMedium
    onClicked: pageStack.push(Qt.resolvedUrl(page))

    Icon {
        id: image
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        opacity: item.enabled ? 1.0 : Theme.opacityLow
    }

    Column {
        anchors {
            left: image.right; leftMargin: Theme.paddingLarge
            right: parent.right; rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        opacity: item.enabled ? 1.0 : Theme.opacityLow

        Label {
            id: titleLabel
            width: parent.width
            truncationMode: TruncationMode.Fade
            color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
        }
        Label {
            id: descriptionLabel
            width: parent.width
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: item.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
    }
}
