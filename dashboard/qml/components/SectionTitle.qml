import QtQuick

Row {
    property string text: ""
    spacing: 6
    height: 22

    Rectangle {
        width: 2; height: 12
        color: "#4A9EE0"
        anchors.verticalCenter: parent.verticalCenter
        radius: 1
    }

    Text {
        text: parent.text
        color: "#7A8A99"
        font.pixelSize: 10
        font.letterSpacing: 1
        anchors.verticalCenter: parent.verticalCenter
    }
}