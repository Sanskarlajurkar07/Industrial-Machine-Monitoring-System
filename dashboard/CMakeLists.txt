cmake_minimum_required(VERSION 3.16)
project(IndustrialMonitorQML VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core Quick QuickControls2 Charts WebSockets Network
)

qt_add_executable(IndustrialMonitorQML
    main.cpp
    BackendBridge.cpp   BackendBridge.h
    MachineModel.cpp    MachineModel.h
    AlertModel.cpp      AlertModel.h
)

qt_add_resources(IndustrialMonitorQML "qml"
    PREFIX "/"
    FILES
        main.qml
        qml/layout/sidebar.qml
        qml/layout/TopBar.qml
        qml/layout/RightPanel.qml
        qml/components/MachineCard.qml
        qml/components/AlertItem.qml
        qml/components/SectionTitle.qml
        qml/components/LiveChart.qml
        qml/pages/Dashboard.qml
)

target_link_libraries(IndustrialMonitorQML PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Charts
    Qt6::WebSockets
    Qt6::Network
)