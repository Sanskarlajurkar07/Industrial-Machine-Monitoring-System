import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: dashboard
    color: "#0B0F14"
    clip: true

    property var machines
    property var alerts
    property string selectedMachineId: "M-001"

    signal machineSelected(string machineId)

    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentWidth: parent.width

        ColumnLayout {
            width: dashboard.width
            spacing: 0

            // ── Machine Overview ─────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight:
                    machineCol.height + 24

                Column {
                    id: machineCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    spacing: 8

                    SectionTitle {
                        text: "MACHINE OVERVIEW"
                    }

                    GridView {
                        id: machineGrid
                        width: parent.width
                        height: (machines && machines.count > 0)
                            ? Math.ceil(machines.count / 4)
                              * 118 + 8
                            : 118
                        cellWidth: width / 4
                        cellHeight: 118
                        model: machines ? machines : null
                        interactive: false

                        delegate: Item {
                            width: machineGrid.cellWidth
                            height: machineGrid.cellHeight

                            MachineCard {
                                anchors.fill: parent
                                anchors.margins: 4
                                machineId:   model.machineId
                                machineName: model.machineName
                                    ? model.machineName
                                    : model.machineId
                                status:      model.status
                                temperature: model.temperature
                                    ? model.temperature : 0
                                rpm:         model.rpm
                                    ? model.rpm : 0
                                vibration:   model.vibration
                                    ? model.vibration : 0

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedMachineId =
                                            model.machineId
                                        dashboard.machineSelected(
                                            model.machineId
                                        )
                                    }
                                }
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

            // ── Machine Details ──────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 260

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Tabs row
                    Row {
                        width: parent.width
                        spacing: 0

                        SectionTitle {
                            text: "MACHINE DETAILS: "
                                + selectedMachineId
                        }

                        Item { width: 16; height: 1 }

                        Row {
                            id: tabRow
                            spacing: 0
                            property int activeTab: 0

                            Repeater {
                                model: ["OVERVIEW",
                                    "TEMPERATURE",
                                    "VIBRATION",
                                    "RPM","POWER"]

                                Rectangle {
                                    width: tabTxt.width + 18
                                    height: 26
                                    color: "transparent"

                                    Rectangle {
                                        visible: index ===
                                            tabRow.activeTab
                                        width: parent.width
                                        height: 2
                                        color: "#4A9EE0"
                                        anchors.bottom:
                                            parent.bottom
                                    }

                                    Text {
                                        id: tabTxt
                                        anchors.centerIn:
                                            parent
                                        text: modelData
                                        color: index ===
                                            tabRow.activeTab
                                            ? "#C7D1DB"
                                            : "#4A5A6A"
                                        font.pixelSize: 9
                                        font.letterSpacing: 0.3
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked:
                                            tabRow.activeTab
                                            = index
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Row {
                            spacing: 5
                            anchors.verticalCenter:
                                parent.verticalCenter

                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: "#00FF9C"
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        to: 0.2; duration: 800
                                    }
                                    NumberAnimation {
                                        to: 1.0; duration: 800
                                    }
                                }
                            }

                            Text {
                                text: "LIVE"
                                color: "#00FF9C"
                                font.pixelSize: 9
                                anchors.verticalCenter:
                                    parent.verticalCenter
                            }
                        }
                    }

                    // Detail body
                    Row {
                        width: parent.width
                        height: 180
                        spacing: 10

                        // Machine info panel
                        Rectangle {
                            width: 170
                            height: parent.height
                            color: "#0D1520"
                            border.color: "#1E2A38"
                            border.width: 1
                            radius: 2

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 0

                                Repeater {
                                    model: [
                                        { k:"TYPE",
                                          v:"CNC MILLING" },
                                        { k:"STATUS",
                                          v:"RUNNING" },
                                        { k:"OPERATOR",
                                          v:"John Smith" },
                                        { k:"SHIFT",
                                          v:"Morning" },
                                        { k:"START",
                                          v:"06:00 AM" },
                                        { k:"RUN TIME",
                                          v:"4h 24m" },
                                        { k:"MAINT DUE",
                                          v:"15 Jun 2025" },
                                    ]

                                    Rectangle {
                                        width: parent ?
                                            parent.width : 150
                                        height: 22
                                        color: "transparent"

                                        Row {
                                            anchors.fill: parent
                                            Text {
                                                text: modelData.k
                                                color: "#3A5068"
                                                font.pixelSize: 8
                                                width: 66
                                                anchors
                                                .verticalCenter:
                                                parent.verticalCenter
                                            }
                                            Text {
                                                text: modelData.v
                                                color: modelData.k
                                                    === "STATUS"
                                                    ? "#00FF9C"
                                                    : "#C7D1DB"
                                                font.pixelSize: 9
                                                anchors
                                                .verticalCenter:
                                                parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Live chart
                        Rectangle {
                            width: parent.width - 180
                            height: parent.height
                            color: "#0D1520"
                            border.color: "#1E2A38"
                            border.width: 1
                            radius: 2

                            Text {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 8
                                text: "°C"
                                color: "#4A5A6A"
                                font.pixelSize: 8
                            }

                            LiveChart {
                                id: mainChart
                                anchors.fill: parent
                                anchors.margins: 4
                                lineColor: "#00FF9C"
                                minY: 0
                                maxY: 120
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

            // ── Stats Row ────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 120

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    // Utilization
                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: parent.height
                        color: "#0D1520"
                        border.color: "#1E2A38"
                        border.width: 1
                        radius: 2

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter:
                                parent.verticalCenter
                            spacing: 6

                            SectionTitle {
                                text: "UTILIZATION"
                            }

                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 52; height: 52
                                    radius: 26
                                    color: "transparent"
                                    border.color: "#00FF9C"
                                    border.width: 4

                                    Text {
                                        anchors.centerIn:
                                            parent
                                        text: "68%"
                                        color: "#C7D1DB"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                Row {
                                    spacing: 3
                                    anchors.bottom:
                                        parent.bottom

                                    Repeater {
                                        model: [
                                            22,34,28,38,
                                            25,30,18
                                        ]

                                        Rectangle {
                                            width: 7
                                            height: modelData
                                            color: "#00FF9C"
                                            anchors.bottom:
                                                parent.bottom
                                            radius: 1
                                            opacity: 0.7
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Production
                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: parent.height
                        color: "#0D1520"
                        border.color: "#1E2A38"
                        border.width: 1
                        radius: 2

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter:
                                parent.verticalCenter
                            spacing: 6

                            SectionTitle {
                                text: "PRODUCTION COUNT"
                            }

                            Text {
                                text: "1,248"
                                color: "#C7D1DB"
                                font.pixelSize: 22
                            }

                            Rectangle {
                                width: parent.width
                                height: 3
                                color: "#1E2A38"
                                radius: 2

                                Rectangle {
                                    width: parent.width
                                        * 0.624
                                    height: parent.height
                                    color: "#00FF9C"
                                    radius: 2
                                }
                            }

                            Row {
                                width: parent.width
                                Text {
                                    text: "Target"
                                    color: "#4A5A6A"
                                    font.pixelSize: 8
                                }
                                Item {
                                    width: parent.width
                                        - 48 - 30
                                    height: 1
                                }
                                Text {
                                    text: "2,000"
                                    color: "#4A5A6A"
                                    font.pixelSize: 8
                                }
                            }
                        }
                    }

                    // Downtime
                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: parent.height
                        color: "#0D1520"
                        border.color: "#1E2A38"
                        border.width: 1
                        radius: 2

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter:
                                parent.verticalCenter
                            spacing: 5

                            SectionTitle {
                                text: "DOWNTIME"
                            }

                            Text {
                                text: "45m"
                                color: "#FF5252"
                                font.pixelSize: 24
                            }

                            Repeater {
                                model: [
                                    { c:"#FF5252",
                                      l:"Breakdown",
                                      v:"20m" },
                                    { c:"#FFC107",
                                      l:"Setup",
                                      v:"10m" },
                                    { c:"#6C757D",
                                      l:"Waiting",
                                      v:"15m" },
                                ]

                                Row {
                                    spacing: 5
                                    Rectangle {
                                        width: 6; height: 6
                                        radius: 1
                                        color: modelData.c
                                        anchors.verticalCenter:
                                            parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.l
                                        color: "#4A5A6A"
                                        font.pixelSize: 8
                                    }
                                    Text {
                                        text: modelData.v
                                        color: modelData.c
                                        font.pixelSize: 8
                                    }
                                }
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

            // ── Event Log ────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: evCol.height + 20

                Column {
                    id: evCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    spacing: 6

                    SectionTitle { text: "EVENT LOG" }

                    Rectangle {
                        width: parent.width
                        height: 26
                        color: "#0D1520"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 0

                            Repeater {
                                model: [
                                    { t:"TIME",      w:0.13 },
                                    { t:"MACHINE",   w:0.10 },
                                    { t:"EVENT",     w:0.18 },
                                    { t:"DESCRIPTION",w:0.34 },
                                    { t:"SEVERITY",  w:0.13 },
                                    { t:"USER",      w:0.12 },
                                ]

                                Text {
                                    width: parent.parent.width
                                        * modelData.w
                                    text: modelData.t
                                    color: "#3A5068"
                                    font.pixelSize: 8
                                    font.letterSpacing: 0.3
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                            }
                        }
                    }

                    ListView {
                        width: parent.width
                        height: 165
                        model: ListModel {
                            ListElement {
                                time:"10:23 AM"
                                machineId:"M-004"
                                event:"Over Temperature"
                                description:"Temperature exceeded threshold"
                                severity:"CRITICAL"
                                user:"System"
                            }
                            ListElement {
                                time:"10:21 AM"
                                machineId:"M-002"
                                event:"Vibration High"
                                description:"Vibration above normal range"
                                severity:"WARNING"
                                user:"System"
                            }
                            ListElement {
                                time:"10:18 AM"
                                machineId:"M-001"
                                event:"Machine Started"
                                description:"Machine started by operator"
                                severity:"INFO"
                                user:"John Smith"
                            }
                            ListElement {
                                time:"10:15 AM"
                                machineId:"M-006"
                                event:"Maintenance Done"
                                description:"Scheduled maintenance completed"
                                severity:"INFO"
                                user:"Technician"
                            }
                            ListElement {
                                time:"10:07 AM"
                                machineId:"M-007"
                                event:"Motor Load High"
                                description:"Motor nearing maximum capacity"
                                severity:"WARNING"
                                user:"System"
                            }
                        }
                        interactive: false

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 32
                            color: index % 2 === 0
                                ? "transparent"
                                : "#0D1520"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                spacing: 0

                                Text {
                                    width: parent.parent.width
                                        * 0.13
                                    text: model.time
                                    color: "#7A8A99"
                                    font.pixelSize: 9
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                                Text {
                                    width: parent.parent.width
                                        * 0.10
                                    text: model.machineId
                                    color: "#C7D1DB"
                                    font.pixelSize: 9
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                                Text {
                                    width: parent.parent.width
                                        * 0.18
                                    text: model.event
                                    color: "#C7D1DB"
                                    font.pixelSize: 9
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                                Text {
                                    width: parent.parent.width
                                        * 0.34
                                    text: model.description
                                    color: "#7A8A99"
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                                Item {
                                    width: parent.parent.width
                                        * 0.13
                                    height: parent.height

                                    Rectangle {
                                        width: sevTxt.width
                                            + 10
                                        height: 16
                                        radius: 2
                                        color: "transparent"
                                        border.width: 1
                                        border.color: {
                                            if(model.severity
                                               ==="CRITICAL")
                                                return "#FF5252"
                                            if(model.severity
                                               ==="WARNING")
                                                return "#FFC107"
                                            return "#4A9EE0"
                                        }
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        Text {
                                            id: sevTxt
                                            anchors.centerIn:
                                                parent
                                            text: model.severity
                                            color: {
                                                if(model.severity
                                                   ==="CRITICAL")
                                                    return "#FF5252"
                                                if(model.severity
                                                   ==="WARNING")
                                                    return "#FFC107"
                                                return "#4A9EE0"
                                            }
                                            font.pixelSize: 7
                                            font.bold: true
                                        }
                                    }
                                }
                                Text {
                                    width: parent.parent.width
                                        * 0.12
                                    text: model.user
                                    color: "#7A8A99"
                                    font.pixelSize: 9
                                    anchors.verticalCenter:
                                        parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                anchors.bottom: parent.bottom
                                color: "#1E2A38"
                            }
                        }
                    }
                }
            }

            Item { height: 12 }
        }
    }
}