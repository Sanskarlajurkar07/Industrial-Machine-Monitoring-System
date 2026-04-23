#pragma once
#include <QAbstractListModel>
#include <QList>

struct Machine {
    QString machineId;
    QString machineName;
    QString status;
    double  temperature = 0;
    int     rpm         = 0;
    double  vibration   = 0;
    double  pressure    = 0;
    QString timestamp;
};

class MachineModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        MachineIdRole = Qt::UserRole + 1,
        MachineNameRole,
        StatusRole,
        TemperatureRole,
        RpmRole,
        VibrationRole,
        PressureRole,
        TimestampRole
    };

    explicit MachineModel(QObject* parent = nullptr);

    int rowCount(
        const QModelIndex& parent = QModelIndex()
    ) const override;

    QVariant data(
        const QModelIndex& index,
        int role = Qt::DisplayRole
    ) const override;

    QHash<int, QByteArray> roleNames() const override;

    void updateMachine(const Machine& machine);
    void initializeMachines(const QList<Machine>& machines);

signals:
    void countChanged();

private:
    QList<Machine> m_machines;
    int findMachine(const QString& machineId) const;
};