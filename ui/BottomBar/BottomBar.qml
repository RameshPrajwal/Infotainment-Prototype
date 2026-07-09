import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: bottomBar
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    color: "black"
    height: parent.height / 12

    RowLayout {
        id: barLayout
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 40

        Image {
            id: carSettingsIcon
            source: "qrc:/ui/assets/car-icon.png"
            fillMode: Image.PreserveAspectFit

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: bottomBar.height * 0.9
            Layout.preferredWidth: bottomBar.width * 0.1
        }

        HVACComponent {
            id: driverHVACControl
            hvacController: driverHVAC

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: bottomBar.height * 0.9
            Layout.preferredWidth: bottomBar.width * 0.1
        }

        Item {
                Layout.preferredWidth: 580
            }

        HVACComponent {
            id: passengerHVACControl
            hvacController: passengerHVAC

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: bottomBar.height * 0.9
            Layout.preferredWidth:  bottomBar.width * 0.1
        }

        VolumeControlComponent {
            id: volumeComponent

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: bottomBar.height * 0.9
            Layout.preferredWidth:  bottomBar.width * 0.1
        }
    }
}
