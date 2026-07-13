pragma Singleton
import QtQuick 2.15

QtObject {
    property var iconSources: [
        "qrc:/ui/assets/car-icon-front.png",
        "qrc:/ui/assets/car-icon-right.png",
        "qrc:/ui/assets/car-icon-left.png"
    ]

    property var imageLeftScreenSources: [
        "qrc:/ui/assets/front-facing-carimage.png",
        "qrc:/ui/assets/right-facing-carimage.png",
        "qrc:/ui/assets/left-facing-carimage.png"
    ]

    property int currentIndex: 0
    property url currentSource: iconSources[currentIndex]
    property url currentLeftScreenSource: imageLeftScreenSources[currentIndex]

    }
