#include "AlertModel.h"

AlertModel::AlertModel(QObject* parent)
    : QAbstractListModel(parent)
{}

int AlertModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_alerts.size();
}

QVariant AlertModel::data(
    const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= m_alerts.size())
        return QVariant();

    const Alert& a = m_alerts[index.row()];

    switch (role) {
    case MachineIdRole:   return a.machineId;
    case MachineNameRole: return a.machineName;
    case SeverityRole:    return a.severity;
    case ParameterRole:   return a.parameter;
    case MessageRole:     return a.message;
    case TriggeredAtRole: return a.triggeredAt;
    case StatusRole:      return a.status;
    }
    return QVariant();
}

QHash<int, QByteArray> AlertModel::roleNames() const {
    return {
        { MachineIdRole,   "machineId"   },
        { MachineNameRole, "machineName" },
        { SeverityRole,    "severity"    },
        { ParameterRole,   "parameter"   },
        { MessageRole,     "message"     },
        { TriggeredAtRole, "triggeredAt" },
        { StatusRole,      "status"      }
    };
}

void AlertModel::addAlert(const Alert& alert) {
    if (m_alerts.size() >= MAX_ALERTS) {
        beginRemoveRows(QModelIndex(),
            m_alerts.size()-1, m_alerts.size()-1);
        m_alerts.removeLast();
        endRemoveRows();
    }

    beginInsertRows(QModelIndex(), 0, 0);
    m_alerts.prepend(alert);
    endInsertRows();

    emit countChanged();
    emit newAlert(alert);
}

void AlertModel::clearAlerts() {
    beginResetModel();
    m_alerts.clear();
    endResetModel();
    emit countChanged();
}