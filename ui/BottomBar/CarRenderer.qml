import QtQuick 2.15
import "../"

Item {
    id: carRenderer

    property color fontColor: "#f0eded"

    Image {
            id: carSettingsIcon
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height
            source: CarViewState.currentSource
            fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: {
                CarViewState.currentIndex = 0
            }
        }
    }

    Rectangle {
        id: decrementButton
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: height / 2
        color: "black"

        Text {
            id: decrementText
            color: carRenderer.fontColor
            anchors.centerIn: parent
            text: "<"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                CarViewState.currentIndex = 2
            }
        }
    }

    Rectangle {
        id: incrementButton
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: height / 2
        color: "black"
        Text {
            color: carRenderer.fontColor
            anchors.centerIn: parent
            text: ">"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                CarViewState.currentIndex = 1
            }
        }
    }


}
