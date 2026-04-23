import QtQuick

Rectangle {
    id: card
    height: 110
    color: "#121821"
    radius: 2
    border.width: 1
    border.color: Qt.rgba(
        statusColor().r,
        statusColor().g,
        statusColor().b,
        0.3
    )

    property string machineId:   "M-001"
    property string machineName: "MACHINE"
    property string status:      "RUNNING"
    property real   temperature: 0
    property int    rpm:         0
    property real   vibration:   0
    property real   pressure:    0

    function statusColor() {
        switch(status) {
        case "RUNNING": return Qt.color("#00FF9C")
        case "WARNING": return Qt.color("#FFC107")
        case "FAULT":   return Qt.color("#FF5252")
        default:        return Qt.color("#6C757D")
        }
    }

    // Top accent bar
    Rectangle {
        width: parent.width
        height: 2
        color: statusColor()
        opacity: 0.8
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 10
        spacing: 5

        Row {
            width: parent.width

            Column {
                spacing: 1
                Text {
                    text: machineId
                    color: "#C7D1DB"
                    font.pixelSize: 12
                    font.letterSpacing: 0.3
                }
                Text {
                    text: machineName
                    color: "#7A8A99"
                    font.pixelSize: 8
                    font.letterSpacing: 0.3
                }
            }

            Item { width: parent.width
                       - machineIdText.width
                       - statusIndicator.width
                       - 10
                   height: 1 }

            Row {
                id: statusIndicator
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: statusColor()
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        running: status === "FAULT"
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.1; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                }

                Text {
                    text: status
                    color: statusColor()
                    font.pixelSize: 9
                    font.letterSpacing: 0.3
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            width: parent.width; height: 1
            color: "#1E2A38"
        }

        Row {
            width: parent.width
            spacing: 0

            Repeater {
                model: [
                    { label: "TEMP",
                      value: temperature.toFixed(1) + "°",
                      warn: temperature > 90 },
                    { label: "RPM",
                      value: rpm.toString(),
                      warn: rpm === 0 && status !== "RUNNING" },
                    { label: "VIB",
                      value: vibration.toFixed(1),
                      warn: vibration > 4.0 }
                ]

                Column {
                    width: parent.width / 3
                    spacing: 2

                    Text {
                        text: modelData.label
                        color: "#3A5068"
                        font.pixelSize: 8
                        font.letterSpacing: 0.3
                    }

                    Text {
                        text: modelData.value
                        color: modelData.warn
                            ? "#FF5252" : "#C7D1DB"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (typeof machineSelected !== "undefined")
                machineSelected(machineId)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "white"
        opacity: cardMouse.containsMouse ? 0.02 : 0
        radius: 2
    }

    Text {
        id: machineIdText
        text: machineId
        font.pixelSize: 12
        visible: false
    }
}