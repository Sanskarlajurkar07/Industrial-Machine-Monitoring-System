import QtQuick

Rectangle {
    width: parent ? parent.width : 240
    height: 70
    color: "#0F1820"
    radius: 2
    border.width: 1
    border.color: severityColor()
    clip: true

    property string machineId:   ""
    property string machineName: ""
    property string severity:    "WARNING"
    property string alertType:   ""
    property string message:     ""
    property string time:        ""

    function severityColor() {
        if (severity === "CRITICAL") return "#FF5252"
        if (severity === "WARNING")  return "#FFC107"
        return "#4A9EE0"
    }

    Rectangle {
        width: 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: severityColor()
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Row {
            width: parent.width
            spacing: 6

            Rectangle {
                height: 16
                width: machBadge.width + 8
                color: Qt.rgba(
                    severity === "CRITICAL" ? 1 : 1,
                    severity === "CRITICAL" ? 0.32 : 0.75,
                    severity === "CRITICAL" ? 0.32 : 0.04,
                    0.2
                )
                radius: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: machBadge
                    anchors.centerIn: parent
                    text: machineId
                    color: severityColor()
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 0.3
                }
            }

            Text {
                text: machineName
                color: "#7A8A99"
                font.pixelSize: 9
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width - 100
            }

            Rectangle {
                height: 16
                width: sevBadge.width + 10
                color: "transparent"
                border.color: severityColor()
                border.width: 1
                radius: 2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: sevBadge
                    anchors.centerIn: parent
                    text: severity
                    color: severityColor()
                    font.pixelSize: 7
                    font.bold: true
                    font.letterSpacing: 0.3
                }
            }
        }

        Text {
            text: alertType
            color: "#C7D1DB"
            font.pixelSize: 10
            elide: Text.ElideRight
            width: parent.width
        }

        Row {
            width: parent.width
            spacing: 8

            Text {
                text: message
                color: "#7A8A99"
                font.pixelSize: 9
                elide: Text.ElideRight
                width: parent.width - 60
            }

            Text {
                text: time
                color: "#3A5068"
                font.pixelSize: 8
                anchors.right: parent.right
            }
        }
    }
}