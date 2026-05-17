@echo off
echo ========================================
echo Running Dashboard with Error Output
echo ========================================
echo.

set PATH=C:\Qt\Tools\mingw1310_64\bin;%PATH%

cd build\Desktop_Qt_6_11_0_MinGW_64_bit-Debug

echo Starting application...
echo.

IndustrialMonitorQML.exe

echo.
echo ========================================
echo Application exited
echo ========================================
pause
