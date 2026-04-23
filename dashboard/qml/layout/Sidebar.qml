import QtQuick
import QtQuick.Layouts

Rectangle {
    color: "#0F141A"
    property int activeIndex: 0

    ListModel {
        id: navModel
        ListElement { label: "DASHBOARD";   icon: "▣" }
        ListElement { label: "MACHINES";    icon: "⚙" }
        ListElement { label: "ALARMS";      icon: "⚠" }
        ListElement { label: "TRENDS";      icon: "↗" }
        ListElement { label: "REPORTS";     icon: "◧" }
        ListElement { label: "MAINTENANCE"; icon: "✦" }
        ListElement { label: "SYSTEM";      icon: "◈" }
        ListElement { label: "SETTINGS";    icon: "⚙" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#080C12"

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 7; height: 7; radius: 4
                    color: "#00FF9C"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "IMMS"
                    color: "#C7D1DB"
                    font.pixelSize: 13
                    font.letterSpacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: navModel
            interactive: false
            clip: true
            topMargin: 8

            delegate: Rectangle {
                width: parent ? parent.width : 140
                height: 42
                color: index === activeIndex
                    ? "#1A2535"
                    : mouseArea.containsMouse
                      ? "#141E2A"
                      : "transparent"

                Rectangle {
                    width: 2
                    height: parent.height * 0.6
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#4A9EE0"
                    visible: index === activeIndex
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        text: model.icon
                        color: index === activeIndex
                            ? "#C7D1DB" : "#4A5A6A"
                        font.pixelSize: 13
                    }

                    Text {
                        text: model.label
                        color: index === activeIndex
                            ? "#C7D1DB" : "#7A8A99"
                        font.pixelSize: 10
                        font.letterSpacing: 0.5
                    }
                }

                Rectangle {
                    visible: model.label === "ALARMS"
                    width: 16; height: 16; radius: 8
                    color: "#FF5252"
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "3"
                        color: "white"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: activeIndex = index
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            color: "#080C12"

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "SYSTEM STATUS"
                    color: "#3A5068"
                    font.pixelSize: 8
                    font.letterSpacing: 1
                }

                Row {
                    spacing: 5
                    Rectangle {
                        width: 6; height: 6; radius: 3
                        color: "#00FF9C"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "ONLINE"
                        color: "#00FF9C"
                        font.pixelSize: 10
                    }
                }

                Text {
                    text: "UPTIME: 5d 14h 23m"
                    color: "#3A5068"
                    font.pixelSize: 8
                }
            }
        }
    }

    Rectangle {
        width: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#1E2A38"
    }
}