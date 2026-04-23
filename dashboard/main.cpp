#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFont>
#include "BackendBridge.h"
#include "MachineModel.h"
#include "AlertModel.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setFont(QFont("Segoe UI", 10));

    // Register types for QML
    qmlRegisterUncreatableType<MachineModel>(
        "Backend", 1, 0, "MachineModel",
        "Created by BackendBridge"
    );
    qmlRegisterUncreatableType<AlertModel>(
        "Backend", 1, 0, "AlertModel",
        "Created by BackendBridge"
    );

    // Create backend bridge
    BackendBridge backend;

    QQmlApplicationEngine engine;

    // Expose to QML as "backendBridge"
    engine.rootContext()->setContextProperty(
        "backendBridge", &backend
    );

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    // Connect to Spring Boot
    backend.connectToBackend("localhost", 8080);

    return app.exec();
}