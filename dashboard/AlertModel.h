#pragma once
#include <QAbstractListModel>
#include <QList>

struct Alert {
    QString machineId;
    QString machineName;
    QString severity;
    QString parameter;
    QString message;
    QString triggeredAt;
    QString status;
};

class AlertModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        MachineIdRole = Qt::UserRole + 1,
        MachineNameRole,
        SeverityRole,
        ParameterRole,
        MessageRole,
        TriggeredAtRole,
        StatusRole
    };

    explicit AlertModel(QObject* parent = nullptr);

    int rowCount(
        const QModelIndex& parent = QModelIndex()
    ) const override;

    QVariant data(
        const QModelIndex& index,
        int role = Qt::DisplayRole
    ) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addAlert(const Alert& alert);
    void clearAlerts();

signals:
    void countChanged();
    void newAlert(const Alert& alert);

private:
    QList<Alert> m_alerts;
    static const int MAX_ALERTS = 50;
};