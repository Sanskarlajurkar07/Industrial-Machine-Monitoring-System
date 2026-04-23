MQTT_BROKER_HOST = "localhost"
MQTT_BROKER_PORT = 1883
MQTT_TOPIC       = "machines/readings"
PUBLISH_INTERVAL = 0.5
ANOMALY_CHANCE   = 0.05

MACHINES = [
    {"id": "M-001", "name": "CNC Machine 1"},
    {"id": "M-002", "name": "CNC Machine 2"},
    {"id": "M-003", "name": "Lathe Machine 1"},
    {"id": "M-004", "name": "Lathe Machine 2"},
    {"id": "M-005", "name": "Milling Machine 1"},
    {"id": "M-006", "name": "Milling Machine 2"},
    {"id": "M-007", "name": "Grinding Machine 1"},
    {"id": "M-008", "name": "Grinding Machine 2"},
    {"id": "M-009", "name": "Drilling Machine 1"},
    {"id": "M-010", "name": "Drilling Machine 2"},
]

NORMAL_RANGES = {
    "temperature": (60.0, 89.0),
    "vibration":   (1.0,  3.9),
    "rpm":         (2000, 3500),
    "pressure":    (10.0, 14.9),
}

ANOMALY_RANGES = {
    "temperature": (91.0, 110.0),
    "vibration":   (4.1,  6.5),
    "rpm":         (500,  1999),
    "pressure":    (15.1, 20.0),
}