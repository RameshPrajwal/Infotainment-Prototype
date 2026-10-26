import QtQuick 2.15

Item {
    id: hotspot

    property real anchorX: 0
    property real anchorY: 0
    property string title: ""
    property string actionText: ""
    property int lineLength: 50
    property url iconSource: ""
    property int iconSize: 22

    property color textPrimary: "#1A1A1A"
    property color textSecondary: "#6E6E66"
    property color backgroundColor: "#F2F1E6"

    signal clicked()

    width: Math.max(label.implicitWidth, 44) + 16
    height: label.implicitHeight + 8
    x: anchorX * parent.width - width / 2
    y: anchorY * parent.height - lineLength - height

    Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    Behavior on lineLength { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: hotspot.backgroundColor
        opacity: 0.85
    }

    Column {
        id: label
        anchors.centerIn: parent

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: hotspot.iconSource.toString() !== ""
            source: hotspot.iconSource
            width: hotspot.iconSize
            height: hotspot.iconSize
            fillMode: Image.PreserveAspectFit
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""
            text: hotspot.title
            font.pixelSize: 13
            color: hotspot.textSecondary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""
            text: hotspot.actionText
            font.pixelSize: 17
            font.bold: true
            color: hotspot.textPrimary
        }
    }

    Rectangle {
        id: line
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: 1
        height: hotspot.lineLength
        color: hotspot.textPrimary
        opacity: 0.5
    }

    Rectangle {
        anchors {
            horizontalCenter: line.horizontalCenter
            verticalCenter: line.bottom
        }
        width: 7; height: 7; radius: 3.5
        color: "white"
        border.color: hotspot.textPrimary
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        cursorShape: Qt.PointingHandCursor
        onClicked: hotspot.clicked()
    }
}
