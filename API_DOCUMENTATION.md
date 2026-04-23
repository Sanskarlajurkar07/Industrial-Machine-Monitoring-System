# API Documentation

## Overview

The Industrial Machine Monitoring System provides a comprehensive REST API for accessing machine data, sensor readings, alerts, and dashboard statistics. All endpoints return JSON responses and follow RESTful conventions.

**Base URL**: `http://localhost:8080/api`

## Authentication

Currently, the API does not require authentication. In production environments, consider implementing:
- JWT tokens for stateless authentication
- API keys for service-to-service communication
- OAuth 2.0 for third-party integrations

## Response Format

### Success Response
```json
{
  "data": { ... },
  "status": "success",
  "timestamp": "2024-01-20T10:30:45Z"
}
```

### Error Response
```json
{
  "error": {
    "code": "MACHINE_NOT_FOUND",
    "message": "Machine with ID M-999 not found",
    "details": "..."
  },
  "status": "error",
  "timestamp": "2024-01-20T10:30:45Z"
}
```

### Pagination Response
```json
{
  "content": [...],
  "page": {
    "number": 0,
    "size": 20,
    "totalElements": 150,
    "totalPages": 8
  },
  "status": "success"
}
```

## Machine Endpoints

### List All Machines

**GET** `/api/machines`

Returns a list of all registered machines in the system.

**Response**
```json
{
  "data": [
    {
      "id": "M-001",
      "name": "CNC Machine 1",
      "status": "NORMAL",
      "location": "Building A - Floor 1",
      "installationDate": "2022-01-15",
      "lastReading": "2024-01-20T10:30:45Z"
    }
  ]
}
```

**Status Codes**
- `200 OK` - Success
- `500 Internal Server Error` - Database connection error

---

### Get Machine Details

**GET** `/api/machines/{machineId}`

Returns detailed information about a specific machine, including its latest sensor reading.

**Parameters**
- `machineId` (path) - Machine identifier (e.g., "M-001")

**Response**
```json
{
  "data": {
    "id": "M-001",
    "name": "CNC Machine 1",
    "status": "WARNING",
    "location": "Building A - Floor 1",
    "installationDate": "2022-01-15",
    "latestReading": {
      "temperature": 92.5,
      "vibration": 3.2,
      "rpm": 2800,
      "pressure": 12.3,
      "timestamp": "2024-01-20T10:30:45Z"
    },
    "activeAlerts": 1
  }
}
```

**Status Codes**
- `200 OK` - Success
- `404 Not Found` - Machine not found
- `500 Internal Server Error` - Database error

---

### Get Machine Sensor Readings

**GET** `/api/machines/{machineId}/readings`

Returns paginated historical sensor readings for a specific machine.

**Parameters**
- `machineId` (path) - Machine identifier
- `start` (query, optional) - Start date (ISO 8601 format)
- `end` (query, optional) - End date (ISO 8601 format)
- `page` (query, optional) - Page number (default: 0)
- `size` (query, optional) - Page size (default: 20, max: 100)

**Example Request**
```
GET /api/machines/M-001/readings?start=2024-01-01T00:00:00Z&end=2024-01-31T23:59:59Z&page=0&size=50
```

**Response**
```json
{
  "content": [
    {
      "id": 12345,
      "machineId": "M-001",
      "temperature": 75.2,
      "vibration": 2.1,
      "rpm": 2950,
      "pressure": 11.8,
      "timestamp": "2024-01-20T10:30:00Z",
      "createdAt": "2024-01-20T10:30:00.123Z"
    }
  ],
  "page": {
    "number": 0,
    "size": 50,
    "totalElements": 5000,
    "totalPages": 100
  }
}
```

**Status Codes**
- `200 OK` - Success
- `400 Bad Request` - Invalid date format or parameters
- `404 Not Found` - Machine not found

---

## Alert Endpoints

### List Alerts

**GET** `/api/alerts`

Returns paginated list of alerts with optional filtering.

**Parameters**
- `machineId` (query, optional) - Filter by machine ID
- `severity` (query, optional) - Filter by severity (WARNING, CRITICAL)
- `status` (query, optional) - Filter by status (OPEN, RESOLVED)
- `page` (query, optional) - Page number (default: 0)
- `size` (query, optional) - Page size (default: 20, max: 100)

**Example Request**
```
GET /api/alerts?machineId=M-001&severity=CRITICAL&status=OPEN&page=0&size=25
```

**Response**
```json
{
  "content": [
    {
      "id": 789,
      "machineId": "M-001",
      "ruleId": 3,
      "ruleName": "Critical Temperature",
      "severity": "CRITICAL",
      "status": "OPEN",
      "message": "Temperature exceeded critical threshold: 95.2°C",
      "triggeredAt": "2024-01-20T10:30:45Z",
      "resolvedAt": null,
      "sensorReading": {
        "temperature": 95.2,
        "vibration": 3.1,
        "rpm": 2850,
        "pressure": 12.1
      }
    }
  ],
  "page": {
    "number": 0,
    "size": 25,
    "totalElements": 15,
    "totalPages": 1
  }
}
```

**Status Codes**
- `200 OK` - Success
- `400 Bad Request` - Invalid filter parameters

---

### Resolve Alert

**PUT** `/api/alerts/{alertId}/resolve`

Manually resolves an open alert.

**Parameters**
- `alertId` (path) - Alert identifier

**Request Body** (optional)
```json
{
  "reason": "Manual resolution after maintenance"
}
```

**Response**
```json
{
  "data": {
    "id": 789,
    "status": "RESOLVED",
    "resolvedAt": "2024-01-20T10:35:00Z",
    "resolvedBy": "manual",
    "reason": "Manual resolution after maintenance"
  }
}
```

**Status Codes**
- `200 OK` - Alert resolved successfully
- `404 Not Found` - Alert not found
- `400 Bad Request` - Alert already resolved

---

## Dashboard Endpoints

### Get Dashboard Summary

**GET** `/api/dashboard/summary`

Returns aggregate statistics for the dashboard overview.

**Response**
```json
{
  "data": {
    "totalMachines": 10,
    "activeAlerts": 3,
    "machinesByStatus": {
      "NORMAL": 7,
      "WARNING": 2,
      "CRITICAL": 1
    },
    "alertsBySeverity": {
      "WARNING": 2,
      "CRITICAL": 1
    },
    "recentActivity": {
      "lastHour": {
        "newAlerts": 2,
        "resolvedAlerts": 1,
        "sensorReadings": 7200
      }
    },
    "systemHealth": {
      "mqttConnected": true,
      "kafkaConnected": true,
      "databaseConnected": true,
      "cacheConnected": true
    }
  }
}
```

**Status Codes**
- `200 OK` - Success
- `500 Internal Server Error` - System error

---

## Alert Rule Endpoints

### List Alert Rules

**GET** `/api/alert-rules`

Returns all configured alert rules.

**Response**
```json
{
  "data": [
    {
      "id": 1,
      "name": "High Temperature Warning",
      "condition": "temperature >= 90 AND temperature < 95",
      "severity": "WARNING",
      "message": "Temperature approaching critical levels",
      "enabled": true,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

---

### Create Alert Rule

**POST** `/api/alert-rules`

Creates a new alert rule.

**Request Body**
```json
{
  "name": "Custom Pressure Rule",
  "condition": "pressure >= 16.0",
  "severity": "WARNING",
  "message": "Pressure elevated beyond normal range",
  "enabled": true
}
```

**Response**
```json
{
  "data": {
    "id": 8,
    "name": "Custom Pressure Rule",
    "condition": "pressure >= 16.0",
    "severity": "WARNING",
    "message": "Pressure elevated beyond normal range",
    "enabled": true,
    "createdAt": "2024-01-20T10:35:00Z"
  }
}
```

**Status Codes**
- `201 Created` - Rule created successfully
- `400 Bad Request` - Invalid rule condition or parameters

---

### Update Alert Rule

**PUT** `/api/alert-rules/{ruleId}`

Updates an existing alert rule.

**Parameters**
- `ruleId` (path) - Rule identifier

**Request Body**
```json
{
  "name": "Updated Pressure Rule",
  "condition": "pressure >= 17.0",
  "severity": "CRITICAL",
  "message": "Critical pressure levels detected",
  "enabled": true
}
```

**Status Codes**
- `200 OK` - Rule updated successfully
- `404 Not Found` - Rule not found
- `400 Bad Request` - Invalid parameters

---

### Delete Alert Rule

**DELETE** `/api/alert-rules/{ruleId}`

Deletes an alert rule (soft delete - marks as disabled).

**Parameters**
- `ruleId` (path) - Rule identifier

**Status Codes**
- `204 No Content` - Rule deleted successfully
- `404 Not Found` - Rule not found

---

## WebSocket API

### Connection

**Endpoint**: `ws://localhost:8080/ws`

**Protocol**: STOMP over WebSocket

### Topics

#### Sensor Readings
**Topic**: `/topic/readings`

**Message Format**:
```json
{
  "machineId": "M-001",
  "temperature": 75.2,
  "vibration": 2.1,
  "rpm": 2950,
  "pressure": 11.8,
  "timestamp": "2024-01-20T10:30:45Z"
}
```

#### Alert Notifications
**Topic**: `/topic/alerts`

**Message Format**:
```json
{
  "id": 789,
  "machineId": "M-001",
  "severity": "CRITICAL",
  "status": "OPEN",
  "message": "Temperature exceeded critical threshold: 95.2°C",
  "triggeredAt": "2024-01-20T10:30:45Z",
  "resolvedAt": null
}
```

### JavaScript Client Example

```javascript
const socket = new SockJS('http://localhost:8080/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({}, function(frame) {
    console.log('Connected: ' + frame);
    
    // Subscribe to sensor readings
    stompClient.subscribe('/topic/readings', function(message) {
        const reading = JSON.parse(message.body);
        console.log('New reading:', reading);
    });
    
    // Subscribe to alerts
    stompClient.subscribe('/topic/alerts', function(message) {
        const alert = JSON.parse(message.body);
        console.log('New alert:', alert);
    });
});
```

---

## Error Codes

| Code | Description | HTTP Status |
|------|-------------|-------------|
| `MACHINE_NOT_FOUND` | Machine with specified ID not found | 404 |
| `ALERT_NOT_FOUND` | Alert with specified ID not found | 404 |
| `RULE_NOT_FOUND` | Alert rule with specified ID not found | 404 |
| `INVALID_DATE_RANGE` | Start date is after end date | 400 |
| `INVALID_RULE_CONDITION` | Rule condition syntax error | 400 |
| `DATABASE_ERROR` | Database connection or query error | 500 |
| `CACHE_ERROR` | Redis cache connection error | 500 |
| `KAFKA_ERROR` | Kafka connection or publishing error | 500 |

---

## Rate Limiting

Currently, no rate limiting is implemented. For production use, consider:

- **Per-IP limits**: 1000 requests per hour
- **Per-endpoint limits**: 100 requests per minute for data endpoints
- **WebSocket connections**: 10 concurrent connections per IP

---

## Data Models

### Machine
```json
{
  "id": "string",           // Machine identifier (M-001 to M-010)
  "name": "string",         // Human-readable name
  "status": "enum",         // NORMAL, WARNING, CRITICAL
  "location": "string",     // Physical location
  "installationDate": "date" // Installation date
}
```

### Sensor Reading
```json
{
  "id": "number",           // Unique identifier
  "machineId": "string",    // Machine reference
  "temperature": "number",  // Temperature in Celsius
  "vibration": "number",    // Vibration in mm/s
  "rpm": "number",          // RPM (revolutions per minute)
  "pressure": "number",     // Pressure in bar
  "timestamp": "datetime",  // Reading timestamp
  "createdAt": "datetime"   // Database insertion time
}
```

### Alert
```json
{
  "id": "number",           // Unique identifier
  "machineId": "string",    // Machine reference
  "ruleId": "number",       // Alert rule reference
  "severity": "enum",       // WARNING, CRITICAL
  "status": "enum",         // OPEN, RESOLVED
  "message": "string",      // Alert description
  "triggeredAt": "datetime", // Alert creation time
  "resolvedAt": "datetime"  // Alert resolution time (null if open)
}
```

### Alert Rule
```json
{
  "id": "number",           // Unique identifier
  "name": "string",         // Rule name
  "condition": "string",    // Evaluation condition
  "severity": "enum",       // WARNING, CRITICAL
  "message": "string",      // Alert message template
  "enabled": "boolean"      // Rule active status
}
```

---

## Testing the API

### Using cURL

```bash
# Get all machines
curl -X GET http://localhost:8080/api/machines

# Get specific machine
curl -X GET http://localhost:8080/api/machines/M-001

# Get machine readings with date range
curl -X GET "http://localhost:8080/api/machines/M-001/readings?start=2024-01-01T00:00:00Z&end=2024-01-31T23:59:59Z&page=0&size=10"

# Get alerts with filters
curl -X GET "http://localhost:8080/api/alerts?severity=CRITICAL&status=OPEN"

# Resolve an alert
curl -X PUT http://localhost:8080/api/alerts/789/resolve \
  -H "Content-Type: application/json" \
  -d '{"reason": "Maintenance completed"}'

# Get dashboard summary
curl -X GET http://localhost:8080/api/dashboard/summary
```

### Using Postman

Import the following collection URL:
```
http://localhost:8080/v3/api-docs
```

This will automatically generate a Postman collection with all available endpoints.

---

## OpenAPI/Swagger Documentation

Interactive API documentation is available at:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs
- **OpenAPI YAML**: http://localhost:8080/v3/api-docs.yaml

The Swagger UI provides:
- Interactive endpoint testing
- Request/response examples
- Schema documentation
- Authentication testing (when implemented)

---

## Changelog

### v1.0.0 (Current)
- Initial API implementation
- Machine and alert endpoints
- WebSocket real-time updates
- Dashboard summary endpoint
- Basic error handling

### Planned Features
- Authentication and authorization
- Rate limiting
- API versioning
- Bulk operations
- Advanced filtering and sorting
- Export capabilities (CSV, Excel)
- Webhook notifications