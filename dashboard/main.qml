import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "qml/layout"
import "qml/pages"

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "Industrial Monitor Dashboard"
    
    Component.onCompleted: {
        console.log("ApplicationWindow completed loading")
    }

    Row {
        anchors.fill: parent

        Sidebar {
            width: 140
            height: parent.height
        }

        Column {
            width: parent.width - 140 - 240
            height: parent.height

            TopBar {
                width: parent.width
                height: 44
                alertCount: backendBridge ? backendBridge.alertCount : 0
                wsConnected: backendBridge ? backendBridge.connected : false
                wsStatus: backendBridge ? backendBridge.connectionStatus : "CONNECTING"
            }

            Dashboard {
                width: parent.width
                height: parent.height - 44
                machines: backendBridge ? backendBridge.machineModel : null
                alerts: backendBridge ? backendBridge.alertModel : null
            }
        }

        RightPanel {
            width: 240
            height: parent.height
            alerts: backendBridge ? backendBridge.alertModel : null
        }
    }
}