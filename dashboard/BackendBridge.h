#pragma once
#include <QObject>
#include <QWebSocket>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>
#include <QJsonObject>
#include "MachineModel.h"
#include "AlertModel.h"

class BackendBridge : public QObject {
    Q_OBJECT

    // Expose to QML
    Q_PROPERTY(MachineModel* machineModel
               READ machineModel CONSTANT)
    Q_PROPERTY(AlertModel* alertModel
               READ alertModel CONSTANT)
    Q_PROPERTY(bool connected
               READ isConnected
               NOTIFY connectionChanged)
    Q_PROPERTY(int alertCount
               READ alertCount
               NOTIFY alertCountChanged)
    Q_PROPERTY(QString connectionStatus
               READ connectionStatus
               NOTIFY connectionChanged)

public:
    explicit BackendBridge(QObject* parent = nullptr);

    MachineModel* machineModel() { return m_machineModel; }
    AlertModel*   alertModel()   { return m_alertModel; }
    bool          isConnected()  const { return m_connected; }
    int           alertCount()   const;
    QString       connectionStatus() const;

    // Called from QML
    Q_INVOKABLE void connectToBackend(
        const QString& host = "localhost",
        int port = 8080
    );
    Q_INVOKABLE void fetchMachines();
    Q_INVOKABLE void fetchAlerts();
    Q_INVOKABLE void resolveAlert(int alertId);

signals:
    void connectionChanged();
    void alertCountChanged();
    void readingReceived(const QString& machineId,
                         double temperature,
                         double vibration,
                         int rpm,
                         double pressure);

private slots:
    void onConnected();
    void onDisconnected();
    void onMessageReceived(const QString& message);
    void onError(QAbstractSocket::SocketError error);
    void tryReconnect();
    void onMachinesReply(QNetworkReply* reply);
    void onAlertsReply(QNetworkReply* reply);

private:
    QWebSocket*            m_socket;
    QNetworkAccessManager* m_network;
    MachineModel*          m_machineModel;
    AlertModel*            m_alertModel;
    QTimer*                m_reconnectTimer;

    QString m_host;
    int     m_port;
    bool    m_connected    = false;
    int     m_reconnectAtt = 0;
    bool    m_stompConnected = false;

    void sendStompConnect();
    void sendStompSubscribe(
        const QString& id,
        const QString& destination
    );
    void processStompMessage(const QString& frame);
    void handleReading(const QJsonObject& obj);
    void handleAlert(const QJsonObject& obj);

    QString determineStatus(
        double temp, double vib, double pressure
    );
};