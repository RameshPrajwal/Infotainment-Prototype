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


    readonly property url carSource:
        CarViewState.leftScreenSource(vehicleState.frunkOpen, vehicleState.trunkOpen)
    readonly property var hotspotLayout: ({
        "closed": { frunk: [0.36, 0.52], trunk: [0.80, 0.29], lock: [0.56, 0.20], charge: [0.885, 0.40] },
        "trunk":  { frunk: [0.36, 0.52], trunk: [0.80, 0.29], lock: [0.56, 0.20], charge: [0.885, 0.40] },
        "frunk":  { frunk: [0.36, 0.50], trunk: [0.80, 0.29], lock: [0.56, 0.20], charge: [0.81, 0.40] },
        "both":   { frunk: [0.36, 0.50], trunk: [0.80, 0.29], lock: [0.56, 0.20], charge: [0.81, 0.40] }
    })
    readonly property var hotspots: hotspotLayout[
        vehicleState.frunkOpen && vehicleState.trunkOpen ? "both"
      : vehicleState.frunkOpen ? "frunk"
      : vehicleState.trunkOpen ? "trunk"
      : "closed"]

    function mx(x) { return CarViewState.facingRight ? 1 - x : x }

    Item {
        id: carView
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 30
        width: parent.width * .95
        height: width * 0.75

        Image {
            id: carRender
            objectName: "leftCarImage"
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: leftScreen.carSource
        }

        Image {
            id: carPrevious
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            opacity: 0
        }

        NumberAnimation {
            id: fadeOut
            target: carPrevious
            property: "opacity"
            to: 0
            duration: 250
        }

        Connections {
            target: leftScreen
            function onCarSourceChanged() {
                carPrevious.source = carRender.source
                carPrevious.opacity = 1
                carRender.source = leftScreen.carSource
                fadeOut.restart()
            }
        }

        Item {
            id: carArea
            anchors.centerIn: carRender
            width: carRender.paintedWidth
            height: carRender.paintedHeight
            visible: CarViewState.isSideView

            CarHotspot {
                objectName: "frunkHotspot"
                anchorX: leftScreen.mx(leftScreen.hotspots.frunk[0])
                anchorY: leftScreen.hotspots.frunk[1]
                lineLength: vehicleState.frunkOpen ? 120 : 70
                title: "Frunk"
                actionText: vehicleState.frunkOpen ? "Close" : "Open"
                textPrimary: leftScreen.textPrimary
                textSecondary: leftScreen.textSecondary
                backgroundColor: leftScreen.color
                onClicked: vehicleState.toggleFrunk()
            }

            CarHotspot {
                objectName: "trunkHotspot"
                anchorX: leftScreen.mx(leftScreen.hotspots.trunk[0])
                anchorY: leftScreen.hotspots.trunk[1]
                lineLength: vehicleState.trunkOpen ? 85 : 45
                title: "Trunk"
                actionText: vehicleState.trunkOpen ? "Close" : "Open"
                textPrimary: leftScreen.textPrimary
                textSecondary: leftScreen.textSecondary
                backgroundColor: leftScreen.color
                onClicked: vehicleState.toggleTrunk()
            }

            CarHotspot {
                id: carLockButton
                objectName: "carLockButton"
                anchorX: leftScreen.mx(leftScreen.hotspots.lock[0])
                anchorY: leftScreen.hotspots.lock[1]
                lineLength: 35
                iconSource: systemHandler.carLocked ? "qrc:/ui/assets/padlock.png"
                                                    : "qrc:/ui/assets/unlock.png"
                textPrimary: leftScreen.textPrimary
                textSecondary: leftScreen.textSecondary
                backgroundColor: leftScreen.color
                onClicked: systemHandler.setCarLocked(!systemHandler.carLocked)
            }

            Rectangle {
                id: chargePortButton
                objectName: "chargePortButton"
                visible: CarViewState.facingLeft
                x: leftScreen.mx(leftScreen.hotspots.charge[0]) * carArea.width - width / 2
                y: leftScreen.hotspots.charge[1] * carArea.height - height / 2
                width: 26; height: 26; radius: 13
                color: vehicleState.charging ? leftScreen.indicatorGreen : "white"
                border.color: vehicleState.charging ? leftScreen.indicatorGreen
                                                    : leftScreen.textPrimary
                Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: "⚡"
                    font.pixelSize: 14
                    color: vehicleState.charging ? "white" : leftScreen.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: vehicleState.toggleCharging()
                }
            }
        }
    }
}
