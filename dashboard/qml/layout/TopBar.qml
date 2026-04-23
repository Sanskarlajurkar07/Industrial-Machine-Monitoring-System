import QtQuick
import QtQuick.Layouts

Rectangle {
    id: topBar
    color: "#0D1219"

    property int alertCount: 3
    property bool wsConnected: false
    property string wsStatus: "CONNECTING"

    property string currentTime: Qt.formatDateTime(
        new Date(), "hh:mm:ss AP"
    )
    property string currentDate: Qt.formatDateTime(
        new Date(), "dd MMM yyyy"
    )

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            topBar.currentTime = Qt.formatDateTime(
                new Date(), "hh:mm:ss AP"
            )
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 10

        Text {
            text: "INDUSTRIAL MACHINE MONITORING SYSTEM"
            color: "#C7D1DB"
            font.pixelSize: 12
            font.letterSpacing: 1
        }

        Item { Layout.fillWidth: true }

        Column {
            spacing: 1
            Layout.rightMargin: 10

            Text {
                text: currentTime
                color: "#C7D1DB"
                font.pixelSize: 12
                anchors.right: parent.right
            }
            Text {
                text: currentDate
                color: "#4A5A6A"
                font.pixelSize: 9
                anchors.right: parent.right
            }
        }

        Rectangle {
            width: 32; height: 32; radius: 4
            color: "#141E2A"

            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: 14
            }

            Rectangle {
                width: 14; height: 14; radius: 7
                color: "#FF5252"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 2
                anchors.rightMargin: 2
                visible: alertCount > 0

                Text {
                    anchors.centerIn: parent
                    text: alertCount
                    color: "white"
                    font.pixelSize: 7
                    font.bold: true
                }
            }
        }

        Rectangle {
            height: 32
            width: userRow.width + 16
            radius: 4
            color: "#141E2A"

            Row {
                id: userRow
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 22; height: 22; radius: 11
                    color: "#2A3A50"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "E"
                        color: "#C7D1DB"
                        font.pixelSize: 10
                    }
                }

                Text {
                    text: "engineer"
                    color: "#C7D1DB"
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Row {
            spacing: 5
            Layout.leftMargin: 4

            Rectangle {
                width: 6; height: 6; radius: 3
                color: wsConnected ? "#00FF9C" : "#FF5252"
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: !wsConnected
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 600 }
                    NumberAnimation { to: 1.0; duration: 600 }
                }
            }

            Text {
                text: wsStatus
                color: wsConnected ? "#00FF9C" : "#FF5252"
                font.pixelSize: 10
                font.letterSpacing: 0.5
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle {
        width: parent.width; height: 1
        anchors.bottom: parent.bottom
        color: "#1E2A38"
    }
}