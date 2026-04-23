#include "BackendBridge.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QUrl>
#include <QDebug>
#include <cmath>

BackendBridge::BackendBridge(QObject* parent)
    : QObject(parent)
    , m_socket(new QWebSocket(QString(),
               QWebSocketProtocol::VersionLatest, this))
    , m_network(new QNetworkAccessManager(this))
    , m_machineModel(new MachineModel(this))
    , m_alertModel(new AlertModel(this))
    , m_reconnectTimer(new QTimer(this))
{
    connect(m_socket, &QWebSocket::connected,
            this, &BackendBridge::onConnected);
    connect(m_socket, &QWebSocket::disconnected,
            this, &BackendBridge::onDisconnected);
    connect(m_socket, &QWebSocket::textMessageReceived,
            this, &BackendBridge::onMessageReceived);
    connect(m_socket, &QWebSocket::errorOccurred,
            this, &BackendBridge::onError);
    connect(m_reconnectTimer, &QTimer::timeout,
            this, &BackendBridge::tryReconnect);
    connect(m_alertModel, &AlertModel::countChanged,
            this, &BackendBridge::alertCountChanged);
}

void BackendBridge::connectToBackend(
    const QString& host, int port)
{
    m_host = host;
    m_port = port;

    QString wsUrl = QString("ws://%1:%2/ws/websocket")
        .arg(host).arg(port);

    qDebug() << "Connecting to:" << wsUrl;
    m_socket->open(QUrl(wsUrl));
}

int BackendBridge::alertCount() const {
    return m_alertModel->rowCount();
}

QString BackendBridge::connectionStatus() const {
    if (m_connected) return "LIVE";
    if (m_reconnectAtt > 0) return "RECONNECTING";
    return "CONNECTING";
}

void BackendBridge::onConnected() {
    qDebug() << "WebSocket connected to Spring Boot";
    m_connected = true;
    m_reconnectAtt = 0;
    m_reconnectTimer->stop();

    sendStompConnect();
    emit connectionChanged();

    // Fetch initial data from REST
    fetchMachines();
    fetchAlerts();
}

void BackendBridge::sendStompConnect() {
    // STOMP CONNECT frame
    QString frame = "CONNECT\n"
                    "accept-version:1.1,1.0\n"
                    "heart-beat:10000,10000\n"
                    "\n";
    frame.append(QChar('\0'));
    m_socket->sendTextMessage(frame);
}

void BackendBridge::sendStompSubscribe(
    const QString& id, const QString& destination)
{
    QString frame = QString("SUBSCRIBE\n"
                            "id:%1\n"
                            "destination:%2\n"
                            "\n")
                    .arg(id, destination);
    frame.append(QChar('\0'));
    m_socket->sendTextMessage(frame);
}

void BackendBridge::onDisconnected() {
    m_connected    = false;
    m_stompConnected = false;
    qDebug() << "Disconnected — reconnecting...";

    // Exponential backoff
    int delay = static_cast<int>(
        std::min(30.0, std::pow(2.0, m_reconnectAtt))
    ) * 1000;
    m_reconnectTimer->start(delay);
    m_reconnectAtt++;

    emit connectionChanged();
}

void BackendBridge::tryReconnect() {
    if (!m_connected) {
        QString wsUrl =
            QString("ws://%1:%2/ws/websocket")
            .arg(m_host).arg(m_port);
        m_socket->open(QUrl(wsUrl));
    }
}

void BackendBridge::onError(
    QAbstractSocket::SocketError error)
{
    qWarning() << "WebSocket error:" << error
               << m_socket->errorString();
}

void BackendBridge::onMessageReceived(
    const QString& message)
{
    // STOMP CONNECTED frame
    if (message.startsWith("CONNECTED")) {
        m_stompConnected = true;
        qDebug() << "STOMP connected — subscribing...";

        sendStompSubscribe("sub-0", "/topic/readings");
        sendStompSubscribe("sub-1", "/topic/alerts");
        return;
    }

    // STOMP MESSAGE frame
    if (message.startsWith("MESSAGE")) {
        processStompMessage(message);
    }
}

void BackendBridge::processStompMessage(
    const QString& frame)
{
    // Find JSON body after double newline
    int bodyStart = frame.indexOf("\n\n");
    if (bodyStart == -1) return;

    QString body = frame.mid(bodyStart + 2)
                       .trimmed()
                       .replace(QChar('\0'), "");

    QJsonDocument doc = QJsonDocument::fromJson(
        body.toUtf8()
    );
    if (!doc.isObject()) return;

    QJsonObject obj = doc.object();

    // Detect type by fields present
    if (obj.contains("temperature")) {
        handleReading(obj);
    } else if (obj.contains("severity")) {
        handleAlert(obj);
    }
}

void BackendBridge::handleReading(const QJsonObject& obj) {
    Machine m;
    m.machineId   = obj["machineId"].toString();
    m.machineName = obj["machineName"].toString();
    m.temperature = obj["temperature"].toDouble();
    m.vibration   = obj["vibration"].toDouble();
    m.rpm         = obj["rpm"].toInt();
    m.pressure    = obj["pressure"].toDouble();
    m.timestamp   = obj["timestamp"].toString();
    m.status      = determineStatus(
        m.temperature, m.vibration, m.pressure
    );

    m_machineModel->updateMachine(m);

    emit readingReceived(
        m.machineId,
        m.temperature,
        m.vibration,
        m.rpm,
        m.pressure
    );
}

void BackendBridge::handleAlert(const QJsonObject& obj) {
    Alert a;
    a.machineId   = obj["machineId"].toString();
    a.severity    = obj["severity"].toString();
    a.parameter   = obj["parameter"].toString();
    a.message     = obj["message"].toString();
    a.triggeredAt = obj["triggeredAt"].toString();
    a.status      = obj["status"].toString();

    m_alertModel->addAlert(a);
}

QString BackendBridge::determineStatus(
    double temp, double vib, double pressure)
{
    if (temp >= 100 || vib >= 5.0 || pressure >= 18.0)
        return "FAULT";
    if (temp >= 90  || vib >= 4.0 || pressure >= 15.0)
        return "WARNING";
    return "RUNNING";
}

// ── REST API calls ──────────────────────────────────────

void BackendBridge::fetchMachines() {
    QString url = QString("http://%1:%2/api/machines")
                  .arg(m_host).arg(m_port);

    QNetworkRequest req{QUrl(url)};
    req.setHeader(
        QNetworkRequest::ContentTypeHeader,
        "application/json"
    );

    QNetworkReply* reply = m_network->get(req);

    connect(reply, &QNetworkReply::finished, this, [=]() {
        onMachinesReply(reply);
    });
}

void BackendBridge::onMachinesReply(QNetworkReply* reply) {
    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Machines API error:"
                   << reply->errorString();
        reply->deleteLater();
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(
        reply->readAll()
    );

    if (!doc.isArray()) {
        reply->deleteLater();
        return;
    }

    QList<Machine> machines;
    for (const QJsonValue& val : doc.array()) {
        QJsonObject obj = val.toObject();
        Machine m;
        m.machineId   = obj["id"].toString();
        m.machineName = obj["name"].toString();
        m.status      = obj["status"].toString();
        machines.append(m);
    }

    if (!machines.isEmpty()) {
        m_machineModel->initializeMachines(machines);
    }

    reply->deleteLater();
}

void BackendBridge::fetchAlerts() {
    QString url =
        QString("http://%1:%2/api/alerts?status=OPEN")
        .arg(m_host).arg(m_port);

    QNetworkRequest req{QUrl(url)};
    QNetworkReply* reply = m_network->get(req);

    connect(reply, &QNetworkReply::finished, this, [=]() {
        onAlertsReply(reply);
    });
}

void BackendBridge::onAlertsReply(QNetworkReply* reply) {
    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(
        reply->readAll()
    );

    // Handle both array and paginated response
    QJsonArray arr;
    if (doc.isArray()) {
        arr = doc.array();
    } else if (doc.isObject()) {
        arr = doc.object()["content"].toArray();
    }

    m_alertModel->clearAlerts();

    for (const QJsonValue& val : arr) {
        QJsonObject obj = val.toObject();
        Alert a;
        a.machineId   = obj["machineId"].toString();
        a.severity    = obj["severity"].toString();
        a.parameter   = obj["parameter"].toString();
        a.message     = obj["message"].toString();
        a.triggeredAt = obj["triggeredAt"].toString();
        a.status      = obj["status"].toString();
        m_alertModel->addAlert(a);
    }

    reply->deleteLater();
}

void BackendBridge::resolveAlert(int alertId) {
    QString url =
        QString("http://%1:%2/api/alerts/%3/resolve")
        .arg(m_host).arg(m_port).arg(alertId);

    QNetworkRequest req{QUrl(url)};
    req.setHeader(
        QNetworkRequest::ContentTypeHeader,
        "application/json"
    );
    m_network->put(req, QByteArray());
}