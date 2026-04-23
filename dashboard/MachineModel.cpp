#include "MachineModel.h"

MachineModel::MachineModel(QObject* parent)
    : QAbstractListModel(parent)
{}

int MachineModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_machines.size();
}

QVariant MachineModel::data(
    const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_machines.size())
        return QVariant();

    const Machine& m = m_machines[index.row()];

    switch (role) {
    case MachineIdRole:    return m.machineId;
    case MachineNameRole:  return m.machineName;
    case StatusRole:       return m.status;
    case TemperatureRole:  return m.temperature;
    case RpmRole:          return m.rpm;
    case VibrationRole:    return m.vibration;
    case PressureRole:     return m.pressure;
    case TimestampRole:    return m.timestamp;
    }
    return QVariant();
}

QHash<int, QByteArray> MachineModel::roleNames() const {
    return {
        { MachineIdRole,   "machineId"   },
        { MachineNameRole, "machineName" },
        { StatusRole,      "status"      },
        { TemperatureRole, "temperature" },
        { RpmRole,         "rpm"         },
        { VibrationRole,   "vibration"   },
        { PressureRole,    "pressure"    },
        { TimestampRole,   "timestamp"   }
    };
}

void MachineModel::updateMachine(const Machine& machine) {
    int idx = findMachine(machine.machineId);

    if (idx >= 0) {
        // Update existing
        m_machines[idx] = machine;
        QModelIndex mi  = index(idx);
        emit dataChanged(mi, mi);
    } else {
        // Add new
        beginInsertRows(QModelIndex(),
            m_machines.size(), m_machines.size());
        m_machines.append(machine);
        endInsertRows();
        emit countChanged();
    }
}

void MachineModel::initializeMachines(
    const QList<Machine>& machines)
{
    beginResetModel();
    m_machines = machines;
    endResetModel();
    emit countChanged();
}

int MachineModel::findMachine(
    const QString& machineId) const
{
    for (int i = 0; i < m_machines.size(); ++i) {
        if (m_machines[i].machineId == machineId)
            return i;
    }
    return -1;
}