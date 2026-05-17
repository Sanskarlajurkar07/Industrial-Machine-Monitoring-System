# Runtime Crash Fix - Application Exits After Loading QML

## Current Status

✅ **Build is working** - IndustrialMonitorQML.exe exists  
✅ **Application starts** - Gets to "Loading QML..."  
❌ **Application exits** - Crashes/exits after QML load

## What I've Done

### 1. Added Error Logging to main.cpp

The app now prints QML errors when it fails to load:
```cpp
if (engine.rootObjects().isEmpty()) {
    qCritical() << "Failed to load QML!";
    qCritical() << "QML Errors:";
    for (const auto& error : engine.errors()) {
        qCritical() << error.toString();
    }
    return -1;
}
```

### 2. Added Debug Logging to main.qml

Added Component.onCompleted to track when the window loads.

## Next Steps - YOU MUST DO THIS

### Step 1: Rebuild the Project

The error logging code I added won't work until you rebuild:

**In Qt Creator:**
1. Build → Clean All
2. Build → Rebuild All

**Or use command line:**
```cmd
cd E:\industrial-monitor\dashboard\build\Desktop_Qt_6_11_0_MinGW_64_bit-Debug
C:\Qt\Tools\mingw1310_64\bin\mingw32-make.exe clean
C:\Qt\Tools\mingw1310_64\bin\mingw32-make.exe
```

### Step 2: Run and Capture Error Output

**Option A: Run from Qt Creator**
1. Click the Run button
2. Look at the "Application Output" pane
3. Copy ALL the output and share it

**Option B: Run from Command Line**
```cmd
cd E:\industrial-monitor\dashboard
debug_run.bat
```

This will show the actual QML error messages.

## Common QML Loading Issues

### Issue 1: QtCharts Not Found

**Symptom:**
```
module "QtCharts" is not installed
```

**Fix:**
1. Open Qt Maintenance Tool
2. Add or remove components
3. Check "Qt Charts" under your Qt version
4. Install
5. Rebuild project

### Issue 2: Resource File Not Updated

**Symptom:**
```
Cannot find file 'qrc:/main.qml'
```

**Fix:**
```cmd
cd build
del /s *.qrc
cmake ..
mingw32-make
```

### Issue 3: QML Syntax Error

**Symptom:**
```
Expected token ';'
```

**Fix:** The error will point to the exact file and line. Fix the syntax error and rebuild.

### Issue 4: Missing QML Import

**Symptom:**
```
module "QtQuick.Controls" is not installed
```

**Fix:** Verify Qt Quick Controls 2 is installed via Qt Maintenance Tool.

## Diagnostic Commands

### Check if QML files are in resources:
```cmd
cd build\Desktop_Qt_6_11_0_MinGW_64_bit-Debug
strings IndustrialMonitorQML.exe | findstr "main.qml"
```

Should show: `qrc:/main.qml`

### Check Qt modules:
```cmd
C:\Qt\6.X.X\mingw_64\bin\qmlimportscanner.exe --help
```

### List available Qt modules:
```cmd
dir C:\Qt\6.X.X\mingw_64\qml
```

Should include:
- QtQuick
- QtQuick.Controls
- QtCharts
- QtWebSockets

## What to Look For in Output

### Good Output (Working):
```
Starting application...
Types registered...
BackendBridge created...
Loading QML...
ApplicationWindow completed loading
QML loaded successfully!
Connecting to: ws://localhost:8080/ws/websocket
Entering event loop...
```

### Bad Output (QML Error):
```
Starting application...
Types registered...
BackendBridge created...
Loading QML...
Failed to load QML!
QML Errors:
file:///E:/industrial-monitor/dashboard/qml/components/LiveChart.qml:2:1: module "QtCharts" is not installed
```

## Temporary Workaround - Test with Simple QML

If you want to test if the basic app works, temporarily modify main.cpp:

```cpp
// Change this line:
engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

// To this:
engine.load(QUrl(QStringLiteral("qrc:/main_test.qml")));
```

Then rebuild. If main_test.qml loads, the issue is in one of your QML files.

## Most Likely Cause

Based on the symptoms, the most likely issues are:

1. **QtCharts module not installed** (LiveChart.qml uses it)
2. **Resource file not properly embedded** (CMake didn't regenerate .qrc)
3. **QML syntax error** in one of the component files

## Action Required

**Please do this NOW:**

1. Rebuild the project (to get error logging)
2. Run the application
3. Copy the COMPLETE output from "Starting application..." to the end
4. Share that output

Then I can tell you exactly what's wrong and how to fix it.

## If QtCharts is the Issue

The LiveChart.qml component uses QtCharts. If this module isn't installed:

**Quick Fix - Comment out LiveChart temporarily:**

Edit `dashboard/qml/pages/Dashboard.qml` and replace the LiveChart with a placeholder:

```qml
// LiveChart {
//     id: mainChart
//     ...
// }

// Replace with:
Rectangle {
    id: mainChart
    anchors.fill: parent
    anchors.margins: 4
    color: "#0D1520"
    Text {
        anchors.centerIn: parent
        text: "Chart Placeholder"
        color: "#7A8A99"
    }
}
```

Then rebuild and test. If it works, you know QtCharts was the issue.
