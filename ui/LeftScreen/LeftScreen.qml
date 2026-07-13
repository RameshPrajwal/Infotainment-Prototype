import QtQuick 2.15
import "../"

Rectangle{
    id: leftScreen
    anchors{
        top: parent.top
        bottom: bottomBar.top
        right: rightScreen.left
        left: parent.left
    }
    color: "white"

    property alias carImageSource: carRender.source

    Image {
        id: carRender
        anchors.centerIn: parent
        width: parent.width * .85
        fillMode: Image.PreserveAspectFit
        source: CarViewState.currentLeftScreenSource
    }
}
