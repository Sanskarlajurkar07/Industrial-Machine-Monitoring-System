import QtQuick

Rectangle {
    id: chart
    color: "#0D1520"
    
    property color lineColor: "#00FF9C"
    property real minY: 0
    property real maxY: 100
    property string chartTitle: ""
    
    // Simple placeholder chart without QtCharts dependency
    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: 20
        
        property var dataPoints: []
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            // Draw grid
            ctx.strokeStyle = "#1E2A38";
            ctx.lineWidth = 1;
            for (var i = 0; i < 4; i++) {
                var y = (height / 3) * i;
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
            
            // Draw line
            if (dataPoints.length > 1) {
                ctx.strokeStyle = lineColor;
                ctx.lineWidth = 2;
                ctx.beginPath();
                
                var xStep = width / (dataPoints.length - 1);
                for (var j = 0; j < dataPoints.length; j++) {
                    var x = j * xStep;
                    var normalizedY = (dataPoints[j] - minY) / (maxY - minY);
                    var y = height - (normalizedY * height);
                    
                    if (j === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }
                ctx.stroke();
            }
        }
    }
    
    property int xCounter: 0
    
    function appendPoint(y) {
        if (canvas.dataPoints.length >= 60) {
            canvas.dataPoints.shift();
        }
        canvas.dataPoints.push(y);
        canvas.requestPaint();
        xCounter++;
    }
    
    Component.onCompleted: {
        canvas.dataPoints = [];
        for (var i = 0; i < 30; i++) {
            var v = minY + (maxY - minY) * 0.6
                + (Math.random() - 0.5) * (maxY - minY) * 0.1;
            canvas.dataPoints.push(v);
        }
        canvas.requestPaint();
    }
}