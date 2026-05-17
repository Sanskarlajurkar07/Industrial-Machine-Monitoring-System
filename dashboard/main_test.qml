import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Test Window"

    Rectangle {
        anchors.fill: parent
        color: "#0B0F14"
        
        Text {
            anchors.centerIn: parent
            text: "Dashboard Test - If you see this, basic QML works!"
            color: "white"
            font.pixelSize: 20
        }
    }
}
