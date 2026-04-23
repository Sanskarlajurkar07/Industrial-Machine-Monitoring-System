CREATE TABLE IF NOT EXISTS machines (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    location VARCHAR(200),
    installation_date DATE
);

CREATE TABLE IF NOT EXISTS sensor_readings (
    id BIGSERIAL PRIMARY KEY,
    machine_id VARCHAR(10) NOT NULL REFERENCES machines(id),
    temperature DOUBLE PRECISION NOT NULL,
    vibration DOUBLE PRECISION NOT NULL,
    rpm INTEGER NOT NULL,
    pressure DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_machine_id 
    ON sensor_readings(machine_id);
CREATE INDEX IF NOT EXISTS idx_timestamp 
    ON sensor_readings(timestamp);
CREATE INDEX IF NOT EXISTS idx_machine_timestamp 
    ON sensor_readings(machine_id, timestamp DESC);

CREATE TABLE IF NOT EXISTS alert_rules (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    condition VARCHAR(500) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    message VARCHAR(500) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS alerts (
    id BIGSERIAL PRIMARY KEY,
    machine_id VARCHAR(10) NOT NULL REFERENCES machines(id),
    rule_id BIGINT NOT NULL REFERENCES alert_rules(id),
    severity VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    message VARCHAR(500) NOT NULL,
    triggered_at TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_alert_machine_status 
    ON alerts(machine_id, status);
CREATE INDEX IF NOT EXISTS idx_alert_status 
    ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alert_triggered_at 
    ON alerts(triggered_at DESC);

INSERT INTO machines (id, name, status, location, installation_date) VALUES
('M-001', 'CNC Machine 1',      'NORMAL', 'Building A - Floor 1', '2022-01-15'),
('M-002', 'CNC Machine 2',      'NORMAL', 'Building A - Floor 1', '2022-02-20'),
('M-003', 'Lathe Machine 1',    'NORMAL', 'Building A - Floor 2', '2022-03-10'),
('M-004', 'Lathe Machine 2',    'NORMAL', 'Building A - Floor 2', '2022-04-05'),
('M-005', 'Milling Machine 1',  'NORMAL', 'Building B - Floor 1', '2022-05-12'),
('M-006', 'Milling Machine 2',  'NORMAL', 'Building B - Floor 1', '2022-06-18'),
('M-007', 'Grinding Machine 1', 'NORMAL', 'Building B - Floor 2', '2022-07-22'),
('M-008', 'Grinding Machine 2', 'NORMAL', 'Building B - Floor 2', '2022-08-30'),
('M-009', 'Drilling Machine 1', 'NORMAL', 'Building C - Floor 1', '2022-09-14'),
('M-010', 'Drilling Machine 2', 'NORMAL', 'Building C - Floor 1', '2022-10-25')
ON CONFLICT (id) DO NOTHING;

INSERT INTO alert_rules (name, condition, severity, message, enabled) VALUES
('High Temp Warning',    'temperature >= 90 AND temperature < 95', 'WARNING',  'Temperature approaching critical levels',  true),
('Critical Temp',        'temperature >= 95',                       'CRITICAL', 'Temperature exceeded critical threshold',   true),
('High Vibration Warn',  'vibration >= 4.0 AND vibration < 5.0',   'WARNING',  'Vibration levels elevated',                true),
('Critical Vibration',   'vibration >= 5.0',                        'CRITICAL', 'Dangerous vibration levels detected',       true),
('Low RPM Warning',      'rpm < 2000',                              'WARNING',  'RPM below normal operating range',          true),
('High Pressure Warn',   'pressure >= 15.0 AND pressure < 18.0',   'WARNING',  'Pressure elevated',                        true),
('Critical Pressure',    'pressure >= 18.0',                        'CRITICAL', 'Pressure at dangerous levels',              true)
ON CONFLICT DO NOTHING;

-- Grant permissions to admin user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO admin;

-- Alter default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO admin;