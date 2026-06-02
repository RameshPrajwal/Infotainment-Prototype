import QtQuick 2.15

Rectangle {
    id: navSearchBox
    radius: 5
    color: "#f0f0f0"

    Image{
       id: searchIcon

       anchors {
           left: parent.left
           leftMargin: 25
           verticalCenter: parent.verticalCenter
       }

       height: parent.height * .45
       fillMode: Image.PreserveAspectFit

       source: "qrc:/ui/assets/search.png"
    }

    Text {
       id: navigationPlaceHolderText
       visible: navigationTextInput.text ===""
       color: "#373737"
       text: "Navigate"
       anchors {
              verticalCenter: parent.verticalCenter
              left: searchIcon.right
              leftMargin: 20
       }
    }

    TextInput {
       id: navigationTextInput
       clip: true
       anchors {
              top: parent.top
              bottom: parent.bottom
              right: parent.right
              left: searchIcon.right
              leftMargin: 20
       }

       verticalAlignment: Text.AlignVCenter
       font.pixelSize: 16

    }
}
