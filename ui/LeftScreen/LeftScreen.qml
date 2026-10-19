import QtQuick 2.15
import "../"

Rectangle {
    id: leftScreen
    anchors {
        top: parent.top
        bottom: bottomBar.top
        right: rightScreen.left
        left: parent.left
    }
    color: "#F2F1E6"

    property alias carImageSource: carRender.source
    property string gear: "P"
    property int speed: 0
    property string driveMode: "CHILL"
    property int batteryPercent: 72

    readonly property color textPrimary: "#1A1A1A"
    readonly property color textSecondary: "#6E6E66"
    readonly property color textInactive: "#B8B8B0"
    readonly property color indicatorGreen: "#2BB24C"
    readonly property int sideMargin: 24

    Row {
        id: gearRow
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 20
            leftMargin: leftScreen.sideMargin
        }
        spacing: 10

        Repeater {
            model: ["P", "R", "N", "D"]
            Text {
                text: modelData
                font.pixelSize: 15
                font.bold: modelData === leftScreen.gear
                color: modelData === leftScreen.gear ? leftScreen.textPrimary
                                                     : leftScreen.textInactive
            }
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: gearRow.verticalCenter
        }
        text: leftScreen.driveMode
        font.pixelSize: 13
        font.letterSpacing: 1.5
        color: leftScreen.textSecondary
    }

    Row {
        anchors {
            right: parent.right
            rightMargin: leftScreen.sideMargin
            verticalCenter: gearRow.verticalCenter
        }
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: leftScreen.batteryPercent + "%"
            font.pixelSize: 14
            color: leftScreen.textPrimary
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Rectangle {
                width: 44; height: 16; radius: 3
                color: "transparent"
                border.color: leftScreen.textPrimary
                border.width: 1.5

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 3 }
                    width: (parent.width - 6) * leftScreen.batteryPercent / 100
                    radius: 1
                    color: leftScreen.batteryPercent <= 20 ? "#E0393E" : leftScreen.textPrimary
                }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 3; height: 6; radius: 1
                color: leftScreen.textPrimary
            }
        }
    }

    Column {
        id: speedBlock
        anchors {
            top: gearRow.bottom
            left: parent.left
            topMargin: 18
            leftMargin: leftScreen.sideMargin
        }
        spacing: -4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: leftScreen.speed
            font.pixelSize: 64
            font.weight: Font.Light
            color: leftScreen.textPrimary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "KM/H"
            font.pixelSize: 12
            font.letterSpacing: 1
            color: leftScreen.textSecondary
        }
    }

    Image {
        id: carRender
        anchors.centerIn: parent
        width: parent.width * .85
        fillMode: Image.PreserveAspectFit
        source: CarViewState.currentLeftScreenSource
    }
}
