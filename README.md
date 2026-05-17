# Industrial Machine Monitoring

Backend for monitoring industrial machines in real-time. Processes sensor data, evaluates alert rules, sends notifications.

## Stack

- Java 8 + Spring Boot
- Kafka for streaming
- PostgreSQL + Redis
- MQTT for IoT data
- WebSocket for live updates

## What it does

Machines send sensor readings (temp, vibration, RPM, pressure) every 500ms via MQTT. Backend consumes these through Kafka, stores in Postgres, caches in Redis, evaluates alert rules, and pushes updates via WebSocket.

```
MQTT → Spring Boot → Kafka → [validate → save → cache → check rules] → alerts/notifications
```

## Running it

Need Docker and Java 8+.

```bash
# Start Kafka, Postgres, Redis, MQTT
cd infra && docker-compose up -d

# Run backend
cd backend/Industrialmonitor
./mvnw spring-boot:run

# Optional: run simulator to generate test data
cd simulator
pip install -r requirements.txt
python sensor_simulator.py
```

Backend: http://localhost:8080

## Interesting parts

**Rule engine** - Built a simple rule engine using SpEL. Rules like `temperature >= 90 AND vibration < 5.0` get compiled to lambdas and cached. Evaluates in ~40ms. Considered Drools but way overkill for threshold checks.

**Kafka partitioning** - 10 partitions keyed by machine ID. Guarantees ordering per machine while processing different machines in parallel. Had issues with consumer lag initially, fixed by batching DB writes.

**Caching** - Redis cache for latest readings with 60s TTL. Hit ratio around 80%. Drops response time from 200ms to 10ms. Tried 30s and 120s TTLs but 60s is the sweet spot.

**Alert management** - Prevents duplicate alerts, auto-resolves when readings normalize, sends Slack notifications for critical stuff. Async with timeout so it doesn't block the pipeline.

## Performance

Load tested with the simulator:
- 20 msg/sec sustained (tested up to 100)
- p95 latency < 200ms end-to-end
- API responses p95 < 500ms
- Rule eval ~40ms per reading

## API

```
GET  /api/machines
GET  /api/machines/{id}
GET  /api/machines/{id}/readings?start=...&end=...
GET  /api/alerts?machineId=...&severity=...
PUT  /api/alerts/{id}/resolve
GET  /api/dashboard/summary
```

WebSocket at `ws://localhost:8080/ws`:
- `/topic/readings` - live sensor data
- `/topic/alerts` - alert notifications

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for details.

## Structure

```
backend/Industrialmonitor/src/main/java/
├── config/          Kafka, Redis, WebSocket setup
├── controller/      REST endpoints
├── service/         Business logic
├── engine/          Rule engine (SpEL compilation)
├── consumer/        Kafka consumers
├── mqtt/            MQTT subscriber
├── repository/      JPA repos
└── modal/           Entities

infra/               Docker compose for services
simulator/           Python script to generate test data
```

## Config

Main settings in `application.yml`:

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
  datasource:
    url: jdbc:postgresql://localhost:5432/machine_monitoring
  redis:
    host: localhost
```

## Why certain choices

**Kafka vs direct processing** - Adds latency but gives durability and scaling. If backend crashes, messages are safe. Can replay if needed.

**Custom rule engine vs Drools** - Drools is powerful but heavy. Our rules are simple thresholds. SpEL is fast and good enough.

**60s cache TTL** - Tested 30s, 60s, 120s. 60s balances freshness vs hit ratio. Real-time monitoring needs relatively fresh data.

**MQTT** - Standard for IoT. Lightweight. Easy for embedded devices.

## Issues/TODO

- No auth on API (would add Spring Security + JWT)
- Single Kafka broker (need 3+ for prod)
- Alert rule validation could be better
- Some service classes getting large
- Need more integration tests

## What I learned

- Kafka partition strategy matters way more than I thought
- SpEL error messages are terrible
- Cache TTL tuning needs actual load testing, not guessing
- WebSocket connection handling is tricky
- Property-based testing catches weird edge cases

## License

MIT
