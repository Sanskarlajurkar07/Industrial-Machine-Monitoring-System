# API Docs

Base: `http://localhost:8080/api`

Everything returns JSON.

## Machines

**List all**
```
GET /api/machines
```

**Get one**
```
GET /api/machines/M-001
```

Returns machine + latest reading.

**Historical data**
```
GET /api/machines/M-001/readings?start=2024-01-01T00:00:00Z&end=2024-01-31T23:59:59Z&page=0&size=50
```

Paginated. Max 100 per page.

## Alerts

**List**
```
GET /api/alerts?machineId=M-001&severity=CRITICAL&status=OPEN&page=0&size=25
```

All params optional.

**Resolve**
```
PUT /api/alerts/789/resolve
```

Optional body:
```json
{"reason": "Fixed after maintenance"}
```

## Dashboard

**Summary stats**
```
GET /api/dashboard/summary
```

Returns machine counts, alert counts, system health.

## Alert Rules

**List**
```
GET /api/alert-rules
```

**Create**
```
POST /api/alert-rules
Content-Type: application/json

{
  "name": "High Pressure",
  "condition": "pressure >= 16.0",
  "severity": "WARNING",
  "message": "Pressure too high",
  "enabled": true
}
```

**Update**
```
PUT /api/alert-rules/1
```

**Delete**
```
DELETE /api/alert-rules/1
```

## WebSocket

Connect: `ws://localhost:8080/ws`

Subscribe to topics:
```javascript
stompClient.subscribe('/topic/readings', function(msg) {
  const data = JSON.parse(msg.body);
  // {machineId, temperature, vibration, rpm, pressure, timestamp}
});

stompClient.subscribe('/topic/alerts', function(msg) {
  const alert = JSON.parse(msg.body);
  // {id, machineId, severity, status, message, triggeredAt}
});
```

## Errors

Standard HTTP codes. Errors return:
```json
{
  "error": {
    "code": "MACHINE_NOT_FOUND",
    "message": "Machine M-999 not found"
  },
  "timestamp": "2024-01-20T10:30:45Z"
}
```

## Testing

```bash
curl http://localhost:8080/api/machines
curl http://localhost:8080/api/machines/M-001
curl "http://localhost:8080/api/alerts?severity=CRITICAL"
curl -X PUT http://localhost:8080/api/alerts/789/resolve
```

Swagger UI: http://localhost:8080/swagger-ui.html
