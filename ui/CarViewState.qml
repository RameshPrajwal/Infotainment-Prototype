pragma Singleton
import QtQuick 2.15

QtObject {
    // Which car view is selected in the bottom bar:
    // 0 = front, 1 = right side, 2 = left side
    property int currentIndex: 0

    property var iconSources: [
        "qrc:/ui/assets/car-icon-front.png",
        "qrc:/ui/assets/car-icon-right.png",
        "qrc:/ui/assets/car-icon-left.png"
    ]
    property url currentSource: iconSources[currentIndex]

    readonly property bool isSideView: currentIndex !== 0
    readonly property bool facingRight: currentIndex === 1

    // Car image for the left screen. The side views have one render per body
    // state (closed, frunk open, trunk open, both open); the front view has
    // a single image.
    function leftScreenSource(frunkOpen, trunkOpen) {
        if (!isSideView)
            return "qrc:/ui/assets/front-facing-carimage.png"

        const state = frunkOpen && trunkOpen ? "both"
                    : frunkOpen ? "frunk"
                    : trunkOpen ? "trunk"
                    : "closed"
        return "qrc:/ui/assets/car/car-" + (facingRight ? "right" : "left")
               + "-" + state + ".png"
    }
}
