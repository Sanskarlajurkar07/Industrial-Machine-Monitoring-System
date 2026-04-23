# Industrial Machine Monitoring & Alert System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java](https://img.shields.io/badge/Java-8+-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.x-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/)
[![Qt](https://img.shields.io/badge/Qt-6.x-green.svg)](https://www.qt.io/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)

A real-time IoT-based monitoring solution that tracks sensor data from industrial machines, detects anomalies, generates alerts, and provides real-time visualization through a dashboard.

## 🏗️ Architecture Overview

The system follows an event-driven architecture with the following components:

```
[Simulator] → [MQTT Broker] → [Backend] → [Kafka] → [Processing Pipeline]
                                ↓              ↓
                          [WebSocket] ← [Alert Engine] → [Slack Notifications]
                                ↓              ↓
                          [Dashboard]    [Database & Cache]
```

### Key Components

- **Simulator**: Python application generating realistic sensor data for 10 machines
- **MQTT Broker**: Mosquitto message broker for sensor data ingestion
- **Backend**: Spring Boot application with business logic and APIs
- **Kafka**: Stream processing platform for scalable data handling
- **Database**: PostgreSQL for persistent storage of machines, readings, and alerts
- **Cache**: Redis for fast access to latest sensor readings
- **Dashboard**: Qt C++ desktop application for real-time visualization

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Java 8+ (for development)
- Python 3.9+ (for simulator development)
- Qt 6.x (for dashboard development)

### Running the System

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd industrial-machine-monitoring
   ```

2. **Start infrastructure services**
   ```bash
   cd infra
   docker-compose up -d
   ```

3. **Start the backend**
   ```bash
   cd backend/Industrialmonitor
   ./mvnw spring-boot:run
   ```

4. **Start the simulator**
   ```bash
   cd simulator
   pip install -r requirements.txt
   python sensor_simulator.py
   ```

5. **Access the system**
   - Backend API: http://localhost:8080
   - API Documentation: http://localhost:8080/swagger-ui.html
   - Health Check: http://localhost:8080/actuator/health

## 📊 System Features

### Real-Time Monitoring
- **10 Industrial Machines**: M-001 through M-010
- **4 Sensor Types**: Temperature, Vibration, RPM, Pressure
- **500ms Data Frequency**: Real-time sensor readings
- **Anomaly Injection**: Periodic out-of-range values for testing

### Alert Management
- **7 Configurable Rules**: Temperature, vibration, RPM, and pressure thresholds
- **Two Severity Levels**: WARNING and CRITICAL
- **Automatic Resolution**: Alerts resolve when readings normalize
- **Slack Integration**: Critical alerts sent to Slack webhook

### Data Processing
- **MQTT Ingestion**: Sensor data received via MQTT protocol
- **Kafka Streaming**: Scalable message processing with ordering guarantees
- **Database Persistence**: Historical data stored in PostgreSQL
- **Redis Caching**: Latest readings cached for fast access (60s TTL)

### REST API
- **Machine Endpoints**: List machines, get machine details, historical readings
- **Alert Endpoints**: Query alerts with filtering and pagination
- **Dashboard Endpoint**: Aggregate statistics and summaries

### Real-Time Updates
- **WebSocket Server**: Real-time updates to connected clients
- **Live Charts**: 60-second rolling window of sensor data
- **Alert Notifications**: Instant alert updates in dashboard

## 🏛️ Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Backend | Spring Boot | 2.7.x | Business logic and APIs |
| Language | Java | 8 | Backend development |
| Database | PostgreSQL | 15 | Persistent data storage |
| Cache | Redis | 7 | Fast data access |
| Message Broker | Apache Kafka | 3.x | Stream processing |
| MQTT Broker | Mosquitto | 2.0 | IoT data ingestion |
| Simulator | Python | 3.9+ | Sensor data generation |
| Dashboard | Qt C++ | 6.x | Desktop visualization |
| Containerization | Docker | 20.10+ | Service deployment |

## 📁 Project Structure

```
├── .kiro/specs/                    # Detailed specifications
│   └── industrial-machine-monitoring/
│       ├── requirements.md         # Business requirements
│       ├── design.md              # Technical design
│       └── tasks.md               # Implementation tasks
├── backend/                       # Spring Boot backend
│   └── Industrialmonitor/
│       ├── src/main/java/         # Java source code
│       ├── src/main/resources/    # Configuration files
│       └── pom.xml               # Maven dependencies
├── infra/                        # Infrastructure setup
│   ├── docker-compose.yml        # Service orchestration
│   ├── init.sql                  # Database initialization
│   └── mosquitto.conf            # MQTT broker config
├── simulator/                    # Python sensor simulator
│   ├── sensor_simulator.py       # Main simulator
│   ├── mqtt_publisher.py         # MQTT publishing
│   ├── config.py                 # Configuration
│   └── requirements.txt          # Python dependencies
└── README.md                     # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the `infra/` directory:

```env
# Database
POSTGRES_DB=machine_monitoring
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123

# Slack Integration
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Simulator Settings
MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
PUBLISH_INTERVAL_MS=500
ANOMALY_INTERVAL_SECONDS=30
```

### Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Backend | 8080 | REST API and WebSocket |
| PostgreSQL | 5432 | Database connection |
| Redis | 6379 | Cache access |
| Kafka | 9092 | Message streaming |
| MQTT | 1883 | Sensor data ingestion |
| Zookeeper | 2181 | Kafka coordination |

## 📈 Monitoring & Observability

### Health Checks
- **Backend Health**: `GET /actuator/health`
- **Metrics**: `GET /actuator/metrics`
- **Database Status**: Connection pool and query performance
- **Cache Status**: Redis connection and hit rates

### Logging
- **Structured Logging**: JSON format for machine parsing
- **Log Levels**: INFO for production, DEBUG for development
- **Error Tracking**: Comprehensive error logging with context

### Performance Metrics
- **MQTT to Kafka**: < 100ms latency (p95)
- **Database Persistence**: < 200ms (p95)
- **REST API Response**: < 500ms (p95)
- **WebSocket Delivery**: < 100ms (p95)
- **Rule Evaluation**: < 50ms per reading

## 🧪 Testing Strategy

### Property-Based Testing
- **24 Universal Properties**: Correctness guarantees across all inputs
- **JUnit-Quickcheck**: 100+ iterations per property
- **Custom Generators**: Domain-specific test data generation

### Integration Testing
- **Testcontainers**: Real infrastructure for testing
- **End-to-End Flows**: Complete data pipeline validation
- **WebSocket Testing**: Real-time communication verification

### Performance Testing
- **Load Testing**: 20 messages/second sustained
- **Spike Testing**: Burst to 100 messages/second
- **Endurance Testing**: 24-hour continuous operation

## 🚀 Deployment

### Development Environment
```bash
# Start all services
cd infra && docker-compose up -d

# Run backend in development mode
cd backend/Industrialmonitor && ./mvnw spring-boot:run

# Start simulator
cd simulator && python sensor_simulator.py
```

### Production Deployment
```bash
# Build and deploy all services
docker-compose -f docker-compose.prod.yml up -d

# Scale backend instances
docker-compose up -d --scale backend=3
```

## 📚 API Documentation

### Machine Endpoints
- `GET /api/machines` - List all machines
- `GET /api/machines/{id}` - Get machine with latest reading
- `GET /api/machines/{id}/readings` - Historical readings with pagination

### Alert Endpoints
- `GET /api/alerts` - List alerts with filtering
- `PUT /api/alerts/{id}/resolve` - Manually resolve alert

### Dashboard Endpoint
- `GET /api/dashboard/summary` - Aggregate statistics

### WebSocket Topics
- `/topic/readings` - Real-time sensor readings
- `/topic/alerts` - Alert notifications

## 🔍 Troubleshooting

### Common Issues

**Backend won't start**
- Check database connection in logs
- Verify Kafka and Redis are running
- Ensure MQTT broker is accessible

**No sensor data**
- Check simulator logs for MQTT connection
- Verify MQTT broker is receiving messages
- Check Kafka consumer logs

**Alerts not generating**
- Verify alert rules in database
- Check rule evaluation logs
- Ensure sensor readings violate thresholds

**WebSocket connection fails**
- Check CORS configuration
- Verify WebSocket endpoint accessibility
- Check client connection logs

### Log Locations
- **Backend**: `backend/logs/application.log`
- **Database**: Docker container logs
- **MQTT**: `infra/mosquitto/logs/`
- **Simulator**: Console output

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Run tests**: `./mvnw test`
4. **Commit changes**: `git commit -m 'Add amazing feature'`
5. **Push to branch**: `git push origin feature/amazing-feature`
6. **Open Pull Request**

### Development Guidelines
- Follow Java 8 coding standards
- Write property-based tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

For questions and support:
- **Documentation**: Check the `.kiro/specs/` directory for detailed specifications
- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas

## 🗺️ Roadmap

### Phase 1: Core System ✅
- [x] MQTT data ingestion
- [x] Kafka stream processing
- [x] Database persistence
- [x] Alert rule engine
- [x] REST API endpoints

### Phase 2: Real-Time Features ✅
- [x] WebSocket server
- [x] Redis caching
- [x] Slack notifications
- [x] Dashboard API

### Phase 3: UI Development 🚧
- [ ] Qt C++ dashboard
- [ ] Real-time charts
- [ ] Alert management UI
- [ ] Machine detail views

### Phase 4: Advanced Features 📋
- [ ] Machine learning anomaly detection
- [ ] Historical trend analysis
- [ ] Mobile dashboard app
- [ ] Advanced alerting rules
- [ ] Multi-tenant support

---

**Built with ❤️ for Industrial IoT Monitoring**