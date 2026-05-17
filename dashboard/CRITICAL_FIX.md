# CRITICAL BUILD FIX - Qt Version Issue

## Root Cause Identified

**The build is configured for Qt 6.11.0, which DOES NOT EXIST.**

The error shows:
```
-IC:/Qt/6.11.0/mingw_64/include/QtCore
```

Qt 6.11.0 is not a valid Qt version. The latest Qt 6 versions are:
- Qt 6.5.x (LTS)
- Qt 6.6.x
- Qt 6.7.x  
- Qt 6.8.x (latest)

## Immediate Fix Required

### Step 1: Check Your Actual Qt Installation

Open Command Prompt and run:
```cmd
dir C:\Qt
```

Look for folders like:
- `6.5.3`
- `6.6.0`
- `6.7.0`
- `6.8.0`

### Step 2: Fix Qt Creator Kit Configuration

1. Open **Qt Creator**
2. Go to **Tools** → **Options** → **Kits**
3. Select your active kit (probably "Desktop Qt 6.11.0 MinGW 64-bit")
4. Click **Change** next to "Qt version"
5. Select the CORRECT Qt version that's actually installed (e.g., 6.8.0)
6. Click **OK**

### Step 3: Reconfigure CMake

1. In Qt Creator, right-click on the project
2. Select **Run CMake**
3. Wait for CMake to reconfigure with the correct Qt path

### Step 4: Clean and Rebuild

1. **Build** → **Clean All**
2. **Build** → **Rebuild All**

## Alternative: Manual CMake Configuration

If Qt Creator doesn't fix it automatically:

```cmd
cd E:\industrial-monitor\dashboard
rmdir /s /q build
mkdir build
cd build

REM Replace 6.8.0 with your actual Qt version
set Qt6_DIR=C:\Qt\6.8.0\mingw_64\lib\cmake\Qt6
cmake .. -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH=C:\Qt\6.8.0\mingw_64
C:\Qt\Tools\mingw1310_64\bin\mingw32-make.exe
```

## Verification

After fixing, the build should show:
```
[ 18%] Automatic MOC for target IndustrialMonitorQML
[ 27%] Building CXX object CMakeFiles/IndustrialMonitorQML.dir/main.cpp.obj
[ 36%] Building CXX object CMakeFiles/IndustrialMonitorQML.dir/BackendBridge.cpp.obj
...
[100%] Built target IndustrialMonitorQML
```

And the executable should exist:
```
E:\industrial-monitor\dashboard\build\Desktop_Qt_6_X_X_MinGW_64_bit-Debug\IndustrialMonitorQML.exe
```

## Why This Happened

Possible causes:
1. **Typo in Kit name**: Someone created a kit called "Qt 6.11.0" but pointed it to a different version
2. **Corrupted Qt installation**: Qt Maintenance Tool had an error
3. **Manual kit creation**: Kit was created manually with wrong version number

## If Qt Is Not Installed At All

If you don't have Qt installed:

1. Download **Qt Online Installer** from https://www.qt.io/download-qt-installer
2. Run the installer
3. Select:
   - Qt 6.8.x (or latest 6.x)
   - MinGW 64-bit compiler
   - Qt Charts
   - Qt WebSockets
   - Qt Quick Controls 2
4. Install
5. Open Qt Creator
6. Configure the kit to use the newly installed Qt version

## Quick Diagnostic Commands

Run these to verify your setup:

```cmd
REM Check Qt installation
dir C:\Qt

REM Check MinGW
dir C:\Qt\Tools\mingw1310_64\bin

REM Check CMake
C:\Qt\Tools\CMake_64\bin\cmake.exe --version

REM Check compiler
C:\Qt\Tools\mingw1310_64\bin\g++.exe --version
```

## Expected Output After Fix

When you run the application, you should see:
```
Starting application...
Types registered...
BackendBridge created...
Loading QML...
QML loaded successfully!
Connecting to: ws://localhost:8080/ws/websocket
Entering event loop...
```

NOT:
```
The command "..." could not be started.
```

## Still Having Issues?

If the problem persists after fixing the Qt version:

1. **Check all QML files exist**:
   ```cmd
   dir dashboard\qml\layout\*.qml
   dir dashboard\qml\components\*.qml
   dir dashboard\qml\pages\*.qml
   ```

2. **Verify Qt Charts is installed**:
   - Run Qt Maintenance Tool
   - Check if "Qt Charts" is selected under your Qt version

3. **Check for missing DLLs**:
   After successful build, if the app crashes immediately, copy Qt DLLs:
   ```cmd
   copy C:\Qt\6.X.X\mingw_64\bin\Qt6Core.dll build\
   copy C:\Qt\6.X.X\mingw_64\bin\Qt6Gui.dll build\
   copy C:\Qt\6.X.X\mingw_64\bin\Qt6Quick.dll build\
   REM ... etc
   ```

   Or add Qt to PATH:
   ```cmd
   set PATH=C:\Qt\6.X.X\mingw_64\bin;%PATH%
   ```
