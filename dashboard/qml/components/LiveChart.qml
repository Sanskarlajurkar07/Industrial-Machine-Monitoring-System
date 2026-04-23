import QtQuick
import QtCharts

ChartView {
    id: chart
    antialiasing: true
    backgroundColor: "transparent"
    plotAreaColor: "transparent"
    legend.visible: false
    margins.top: 0
    margins.bottom: 0
    margins.left: 0
    margins.right: 0

    property color lineColor: "#00FF9C"
    property real minY: 0
    property real maxY: 100
    property string chartTitle: ""

    ValueAxis {
        id: axisX
        min: 0; max: 60
        labelsVisible: false
        gridVisible: false
        lineVisible: false
        tickCount: 0
    }

    ValueAxis {
        id: axisY
        min: minY; max: maxY
        labelsColor: "#4A5A6A"
        labelFormat: "%.0f"
        gridLineColor: "#1E2A38"
        lineVisible: false
        tickCount: 4
        labelsFont.pixelSize: 8
    }

    LineSeries {
        id: lineSeries
        axisX: axisX
        axisY: axisY
        color: lineColor
        width: 1.5
    }

    property int xCounter: 0

    function appendPoint(y) {
        if (lineSeries.count >= 60) {
            lineSeries.removePoints(0, 1)
        }
        lineSeries.append(xCounter, y)
        xCounter++
        axisX.min = Math.max(0, xCounter - 60)
        axisX.max = xCounter
    }

    Component.onCompleted: {
        for (var i = 0; i < 30; i++) {
            var v = minY + (maxY - minY) * 0.6
                + (Math.random() - 0.5) * (maxY - minY) * 0.1
            appendPoint(v)
        }
    }
}