import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "Industrial Monitor Dashboard"

    // Main dashboard layout
    Row {
        anchors.fill: parent

        // Sidebar
        Rectangle {
            width: 200
            height: parent.height
            color: "#2c3e50"

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Industrial Monitor"
                    color: "white"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#34495e"
                }

                Button {
                    width: parent.width
                    text: "Dashboard"
                    flat: true
                    
                    background: Rectangle {
                        color: parent.pressed ? "#34495e" : "transparent"
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // Main content area
        Column {
            width: parent.width - 200 - 300 // Sidebar width - Right panel width
            height: parent.height

            // Top bar
            Rectangle {
                width: parent.width
                height: 60
                color: "#ecf0f1"
                border.color: "#bdc3c7"
                border.width: 1

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20

                    Text {
                        text: "Industrial Monitor Dashboard"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#2c3e50"
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 15

                    Rectangle {
                        width: 80
                        height: 30
                        radius: 15
                        color: backendBridge.connected ? "#27ae60" : "#e74c3c"

                        Text {
                            anchors.centerIn: parent
                            text: backendBridge.connectionStatus
                            color: "white"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }
                    }

                    Rectangle {
                        width: 60
                        height: 30
                        radius: 15
                        color: backendBridge.alertCount > 0 ? "#e74c3c" : "#95a5a6"

                        Text {
                            anchors.centerIn: parent
                            text: backendBridge.alertCount + " alerts"
                            color: "white"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }
                    }
                }
            }

            // Main dashboard content
            ScrollView {
                width: parent.width
                height: parent.height - 60 // Subtract top bar height
                clip: true

                Column {
                    width: parent.width
                    spacing: 20
                    anchors.margins: 20

                    Text {
                        text: "Machine Status"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#333333"
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    // Machine cards grid
                    Flow {
                        width: parent.width - 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 15

                        Repeater {
                            model: backendBridge.machineModel
                            delegate: Rectangle {
                                width: 250
                                height: 150
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 8

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 10

                                    Text {
                                        text: model.machineName || "Machine " + (index + 1)
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        color: "#333"
                                    }

                                    Rectangle {
                                        width: 60
                                        height: 20
                                        radius: 10
                                        color: model.status === "RUNNING" ? "#4CAF50" : 
                                               model.status === "WARNING" ? "#FF9800" : "#F44336"

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.status || "UNKNOWN"
                                            color: "white"
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                        }
                                    }

                                    Column {
                                        spacing: 5
                                        
                                        Text {
                                            text: "Temperature: " + (model.temperature || 0).toFixed(1) + "°C"
                                            font.pixelSize: 12
                                            color: "#666"
                                        }
                                        
                                        Text {
                                            text: "Pressure: " + (model.pressure || 0).toFixed(1) + " bar"
                                            font.pixelSize: 12
                                            color: "#666"
                                        }
                                        
                                        Text {
                                            text: "Vibration: " + (model.vibration || 0).toFixed(2) + " mm/s"
                                            font.pixelSize: 12
                                            color: "#666"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right panel for alerts
        Rectangle {
            width: 300
            height: parent.height
            color: "#f8f9fa"
            border.color: "#dee2e6"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Text {
                    text: "Recent Alerts (" + backendBridge.alertCount + ")"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#333333"
                }

                ScrollView {
                    width: parent.width
                    height: parent.height - 50
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: backendBridge.alertModel
                            delegate: Rectangle {
                                width: parent.width - 20
                                height: 60
                                color: "#f5f5f5"
                                border.color: "#ddd"
                                border.width: 1
                                radius: 4

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 10

                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: model.severity === "HIGH" ? "#ff4444" : 
                                               model.severity === "MEDIUM" ? "#ffaa00" : "#44ff44"
                                    }

                                    Column {
                                        Text {
                                            text: model.message || "Alert"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                        }
                                        Text {
                                            text: model.triggeredAt || ""
                                            font.pixelSize: 12
                                            color: "#666"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}