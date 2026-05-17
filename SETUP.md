# Setup

## Quick start

```bash
# 1. Start services
cd infra && docker-compose up -d

# 2. Run backend
cd backend/Industrialmonitor
./mvnw spring-boot:run

# 3. (Optional) Run simulator
cd simulator
pip install -r requirements.txt
python sensor_simulator.py
```

Backend runs on port 8080.

Check: `curl http://localhost:8080/actuator/health`

## What's running

- PostgreSQL on 5432
- Redis on 6379
- Kafka on 9092
- MQTT on 1883

Wait ~30 seconds after `docker-compose up` for Kafka to be ready.

## Config

Database creds in `infra/docker-compose.yml`:
```
DB: machine_monitoring
User: admin
Pass: admin123
```

For Slack notifications, set env var:
```bash
export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK
```

## Troubleshooting

**Backend won't start**
- Check Postgres: `docker ps | grep postgres`
- Check Kafka logs: `docker logs infra_kafka_1`
- Make sure ports aren't in use

**No data showing up**
- Is simulator running?
- Check MQTT logs: `docker logs infra_mosquitto_1`
- Look for "Consumed message" in backend logs

**Alerts not working**
- Check rules exist: `curl http://localhost:8080/api/alert-rules`
- Simulator injects anomalies every 30s
- Check backend logs for rule evaluation

## Stopping

```bash
# Stop backend: Ctrl+C
# Stop simulator: Ctrl+C

# Stop services
cd infra && docker-compose down

# Stop and delete data
docker-compose down -v
```

## Building

```bash
cd backend/Industrialmonitor
./mvnw clean package
java -jar target/industrialmonitor-0.0.1-SNAPSHOT.jar
```

## Tests

```bash
./mvnw test
```
