# Dashboard Build Fix Guide

## Issues Identified

1. **Missing Executable**: The build is not producing `IndustrialMonitorQML.exe`
2. **QML Property Binding**: Potential null pointer access in QML before BackendBridge initialization
3. **Build Configuration**: Possible Qt version mismatch (Qt 6.11.0 doesn't exist)

## Fixes Applied

### 1. QML Null Safety (main.qml)
Added null checks for backendBridge properties:
```qml
alertCount: backendBridge ? backendBridge.alertCount : 0
wsConnected: backendBridge ? backendBridge.connected : false
wsStatus: backendBridge ? backendBridge.connectionStatus : "CONNECTING"
machines: backendBridge ? backendBridge.machineModel : null
alerts: backendBridge ? backendBridge.alertModel : null
```

### 2. Model Null Checks (Dashboard.qml, RightPanel.qml)
Added null checks for model properties to prevent crashes.

## Rebuild Steps

### Option 1: Clean Rebuild in Qt Creator
1. Open Qt Creator
2. Go to **Build** → **Clean All**
3. Go to **Build** → **Rebuild All**
4. Check the **Compile Output** pane for errors

### Option 2: Manual CMake Rebuild
```bash
cd dashboard
rm -rf build
mkdir build
cd build
cmake .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug
cmake --build .
```

### Option 3: Using Qt Creator's CMake
1. Right-click on the project in Qt Creator
2. Select **Run CMake**
3. Then **Build** → **Build Project**

## Common Build Errors and Solutions

### Error: "Qt6Charts not found"
**Solution**: Install Qt Charts module
```bash
# Using Qt Maintenance Tool
# 1. Run Qt Maintenance Tool
# 2. Select "Add or remove components"
# 3. Check "Qt Charts" under your Qt version
# 4. Install
```

### Error: "Cannot find -lQt6::Charts"
**Solution**: Verify CMakeLists.txt has correct Qt components:
```cmake
find_package(Qt6 REQUIRED COMPONENTS
    Core Quick QuickControls2 Charts WebSockets Network
)
```

### Error: "undefined reference to vtable"
**Solution**: Clean and rebuild MOC files
```bash
cd build
rm -rf CMakeFiles
cmake ..
make clean
make
```

### Error: Missing DLLs at runtime
**Solution**: Copy Qt DLLs to build directory or add Qt bin to PATH:
```bash
# Add to PATH (Windows)
set PATH=C:\Qt\6.x.x\mingw_64\bin;%PATH%
```

## Verification Steps

After successful build:
1. Check that `IndustrialMonitorQML.exe` exists in build directory
2. Run the application
3. Verify console output shows:
   ```
   Starting application...
   Types registered...
   BackendBridge created...
   Loading QML...
   QML loaded successfully!
   ```

## Debug Mode

To get more detailed error messages, run from command line:
```bash
cd build/Desktop_Qt_6_11_0_MinGW_64_bit-Debug
./IndustrialMonitorQML.exe
```

Check for:
- QML syntax errors
- Missing imports
- Property binding errors
- WebSocket connection issues

## Additional Checks

1. **Verify Qt Installation**:
   - Qt Creator → Help → About Qt Creator
   - Check Qt version (should be 6.5.x or 6.8.x, NOT 6.11.0)

2. **Check Kit Configuration**:
   - Qt Creator → Tools → Options → Kits
   - Verify compiler, Qt version, and CMake are properly configured

3. **Verify All QML Files Exist**:
   ```bash
   ls -la qml/layout/*.qml
   ls -la qml/components/*.qml
   ls -la qml/pages/*.qml
   ```

## If Build Still Fails

1. Check Qt Creator's **Compile Output** pane for specific errors
2. Look for missing headers or libraries
3. Verify all source files are listed in CMakeLists.txt
4. Check that Qt Charts module is installed
5. Try building a simple Qt Quick example to verify Qt installation

## Contact

If issues persist, provide:
- Full build output from Qt Creator
- Qt version (Help → About Qt Creator)
- CMake version
- Compiler version (g++ --version)
