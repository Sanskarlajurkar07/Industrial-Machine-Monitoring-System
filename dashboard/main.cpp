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

    qDebug() << "Starting application...";

    // Register types for QML
    qmlRegisterUncreatableType<MachineModel>(
        "Backend", 1, 0, "MachineModel",
        "Created by BackendBridge"
    );
    qmlRegisterUncreatableType<AlertModel>(
        "Backend", 1, 0, "AlertModel",
        "Created by BackendBridge"
    );

    qDebug() << "Types registered...";

    // Create backend bridge
    BackendBridge backend;

    qDebug() << "BackendBridge created...";

    QQmlApplicationEngine engine;
    
    // Connect to warnings to see QML errors
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        [](const QList<QQmlError> &warnings) {
            for (const auto &warning : warnings) {
                qWarning() << "QML Warning:" << warning.toString();
            }
        });

    // Expose to QML as "backendBridge"
    engine.rootContext()->setContextProperty(
        "backendBridge", &backend
    );

    qDebug() << "Loading QML...";

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML! Check warnings above.";
        return -1;
    }

    qDebug() << "QML loaded successfully!";

    // Connect to Spring Boot
    backend.connectToBackend("localhost", 8080);

    qDebug() << "Entering event loop...";

    return app.exec();
}