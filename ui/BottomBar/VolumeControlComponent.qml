import QtQuick 2.15

Item {
    id: root
    width: 220
    height: 60

    property color fontColor: "white"
    property color decrementButtonColor: "black"
    property color incrementButtonColor: "black"
    property url iconSource1: "qrc:/ui/assets/volume-1.png"
    property url iconSource2: "qrc:/ui/assets/volume-2.png"
    property url iconSource3: "qrc:/ui/assets/volume-3.png"
    property url iconSource4: "qrc:/ui/assets/volume-mute.png"

    property real buttonWidthRatio: 0.55
    property real iconScale: 0.65
    property int spacing: 12

    readonly property real buttonWidth: root.height * buttonWidthRatio
    readonly property real iconSize: root.height * iconScale

    Connections{
        target: audioController
        function onVolumeLevelChanged(){
            volumeIcon.visible = false
            visibleTimer.stop()
            visibleTimer.start()
        }
    }

    Timer {
        id: visibleTimer
        interval: 1000
        repeat: false
        onTriggered: {
            volumeIcon.visible = true
        }
    }

    Image {
        id: volumeIcon
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source:{
            if (audioController.volumeLevel <= 1)
                return (root.iconSource4)
            else if (audioController.volumeLevel <= 30)
                return (root.iconSource1)
            else if (audioController.volumeLevel <= 60)
                return (root.iconSource2)
            else
                return (root.iconSource3)

        }

        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: volumeLabelText
        visible: !volumeIcon.visible
        anchors {
            centerIn: volumeIcon
        }
        color: fontColor
        font.pixelSize: 24
        text:  audioController.volumeLevel

    }

    Rectangle {
        id: decrementButton
        width: root.buttonWidth
        height: root.height
        radius: height / 6
        color: root.decrementButtonColor

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: volumeIcon.left
        anchors.rightMargin: root.spacing

        Text {
            anchors.centerIn: parent
            text: "-"
            color: root.fontColor
            font.pixelSize: parent.height * 0.42
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: audioController.incrementVolumeLevel(-1)
        }
    }

    Rectangle {
        id: incrementButton
        width: root.buttonWidth
        height: root.height
        radius: height / 6
        color: root.incrementButtonColor

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: volumeIcon.right
        anchors.leftMargin: root.spacing

        Text {
            anchors.centerIn: parent
            text: "+"
            color: root.fontColor
            font.pixelSize: parent.height * 0.42
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: audioController.incrementVolumeLevel(+1)
        }
    }
}
