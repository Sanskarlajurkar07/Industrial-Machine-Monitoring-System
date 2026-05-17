import QtQuick
import QtQuick.Layouts
import "../components"

Rectangle {
    color: "#0B0F14"

    property var alerts
    property int runningCount: 5
    property int warningCount: 2
    property int faultCount:   1

    Rectangle {
        width: 1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#1E2A38"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        anchors.leftMargin: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            SectionTitle { text: "ACTIVE ALERTS" }
            Item { Layout.fillWidth: true }

            Row {
                spacing: 6
                Rectangle {
                    width: 20; height: 20; radius: 10
                    color: "#FF5252"
                    Text {
                        anchors.centerIn: parent
                        text: alerts ? alerts.count : "0"
                        color: "white"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
                Text {
                    text: "View All"
                    color: "#4A9EE0"
                    font.pixelSize: 9
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            Layout.maximumHeight: 280
            model: alerts ? alerts : null
            spacing: 6
            clip: true
            interactive: alerts ? alerts.count > 3 : false

            delegate: AlertItem {
                width: parent ? parent.width : 0
                machineId:   model.machineId
                machineName: model.machineName ?
                    model.machineName : model.machineId
                severity:    model.severity
                alertType:   model.parameter ?
                    model.parameter.toUpperCase() + " Alert"
                    : "Alert"
                message:     model.message
                time:        model.triggeredAt ?
                    model.triggeredAt.substring(11, 19)
                    : ""
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1E2A38"
        }

        SectionTitle { text: "SYSTEM INFORMATION" }

        Column {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: [
                    { label: "PLANT",
                      value: "Plant 01",
                      c: "#C7D1DB" },
                    { label: "LOCATION",
                      value: "Production Hall A",
                      c: "#C7D1DB" },
                    { label: "TOTAL MACHINES",
                      value: "10",
                      c: "#C7D1DB" },
                    { label: "RUNNING",
                      value: runningCount.toString(),
                      c: "#00FF9C" },
                    { label: "WARNING",
                      value: warningCount.toString(),
                      c: "#FFC107" },
                    { label: "FAULT",
                      value: faultCount.toString(),
                      c: "#FF5252" },
                ]

                Rectangle {
                    width: parent ? parent.width : 200
                    height: 26
                    color: index % 2 === 0
                        ? "transparent" : "#0D1520"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4

                        Text {
                            text: modelData.label
                            color: "#4A5A6A"
                            font.pixelSize: 9
                            font.letterSpacing: 0.3
                            anchors.verticalCenter:
                                parent.verticalCenter
                            width: parent.width * 0.62
                        }

                        Text {
                            text: modelData.value
                            color: modelData.c
                            font.pixelSize: 10
                            horizontalAlignment:
                                Text.AlignRight
                            anchors.verticalCenter:
                                parent.verticalCenter
                            width: parent.width * 0.38
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1E2A38"
        }

        SectionTitle { text: "QUICK ACTIONS" }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: [
                    "ADD MACHINE",
                    "MAINTENANCE",
                    "GENERATE REPORT",
                    "SETTINGS"
                ]

                Rectangle {
                    Layout.fillWidth: true
                    height: 34
                    color: "#121821"
                    border.color: "#2A3441"
                    border.width: 1
                    radius: 2

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: "#7A8A99"
                        font.pixelSize: 8
                        font.letterSpacing: 0.3
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width - 8
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            text: "v2.1.0"
            color: "#2A3441"
            font.pixelSize: 8
        }
    }
}