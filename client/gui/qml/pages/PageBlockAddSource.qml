import QtQuick 2.5
import Sailfish.Silica 1.0

// Block the numbers that a lookup source reports as spam
Page {
    id: root

    SilicaListView {
        id: blockSourceView
        anchors.fill: parent
        model: _blocks.sources

        header: PageHeader {
            title: qsTr("Block lookup source results")
            description: qsTr("Numbers the source reports as spam")
        }

        ViewPlaceholder {
            enabled: blockSourceView.count === 0
            text: qsTr("No lookup source to add")
            hintText: qsTr("Only some lookup sources report spam numbers")
        }

        delegate: ListItem {
            id: sourceItem
            onClicked: {
                _bots.setBlockSource(model.id, true)
                _blocks.initBlocks()
                pageStack.pop()
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
                truncationMode: TruncationMode.Fade
                color: sourceItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

        VerticalScrollDecorator {}
    }
}
