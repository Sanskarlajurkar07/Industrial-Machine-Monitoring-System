@echo off
echo ========================================
echo Industrial Monitor Dashboard - Rebuild Script
echo ========================================
echo.

REM Check if Qt is installed
if not exist "C:\Qt" (
    echo ERROR: Qt is not installed in C:\Qt
    echo Please install Qt first or update this script with your Qt path
    pause
    exit /b 1
)

REM Try to find Qt version
echo Searching for Qt installation...
for /d %%i in (C:\Qt\6.*) do (
    if exist "%%i\mingw_64" (
        set QT_PATH=%%i\mingw_64
        echo Found Qt at: %%i
        goto :found_qt
    )
)

echo ERROR: Could not find Qt 6.x with MinGW 64-bit
echo Please check your Qt installation
pause
exit /b 1

:found_qt
echo Using Qt from: %QT_PATH%
echo.

REM Check for MinGW
if not exist "C:\Qt\Tools\mingw1310_64\bin\mingw32-make.exe" (
    echo ERROR: MinGW not found at C:\Qt\Tools\mingw1310_64
    echo Please install MinGW through Qt Maintenance Tool
    pause
    exit /b 1
)

REM Clean old build
echo Cleaning old build directory...
if exist "build" (
    rmdir /s /q build
)

REM Create new build directory
echo Creating build directory...
mkdir build
cd build

REM Run CMake
echo.
echo Running CMake configuration...
set CMAKE_PREFIX_PATH=%QT_PATH%
"C:\Qt\Tools\CMake_64\bin\cmake.exe" .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=%QT_PATH%

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    echo Please check the error messages above
    cd ..
    pause
    exit /b 1
)

REM Build
echo.
echo Building project...
"C:\Qt\Tools\mingw1310_64\bin\mingw32-make.exe"

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo Please check the error messages above
    cd ..
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Executable location:
dir /s /b IndustrialMonitorQML.exe
echo.
echo To run the application:
echo 1. Make sure the backend is running on localhost:8080
echo 2. Run: IndustrialMonitorQML.exe
echo.
cd ..
pause
