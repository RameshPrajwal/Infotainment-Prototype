import QtQuick 2.15
import QtQuick.Window 2.15
import "ui/BottomBar"
import "ui/RightScreen"
import "ui/LeftScreen"

Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("Infotainment")

    LeftScreen{
        id: leftScreen
    }

    RightScreen{
        id: rightScreen
    }

    BottomBar{
        id: bottomBar
    }


}
