# Deployment Guide

This guide provides step-by-step instructions for deploying the Industrial Machine Monitoring System in different environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Environment](#development-environment)
- [Production Environment](#production-environment)
- [Docker Deployment](#docker-deployment)
- [Configuration](#configuration)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)
- [Scaling](#scaling)

## Prerequisites

### System Requirements

**Minimum Requirements:**
- CPU: 4 cores
- RAM: 8 GB
- Storage: 50 GB SSD
- Network: 1 Gbps

**Recommended Requirements:**
- CPU: 8 cores
- RAM: 16 GB
- Storage: 100 GB SSD
- Network: 1 Gbps

### Software Dependencies

**Required Software:**
- Docker 20.10+
- Docker Compose 2.0+
- Git 2.30+

**Development Dependencies:**
- Java 8+ (OpenJDK recommended)
- Maven 3.6+
- Python 3.9+
- Qt 6.x (for dashboard development)

### Network Requirements

**Ports to Open:**
- 8080: Backend API and WebSocket
- 5432: PostgreSQL (if external access needed)
- 6379: Redis (if external access needed)
- 9092: Kafka (if external access needed)
- 1883: MQTT broker
- 2181: Zookeeper (internal)

## Development Environment

### Quick Setup

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd industrial-machine-monitoring
   ```

2. **Start Infrastructure**
   ```bash
   cd infra
   docker-compose up -d
   ```

3. **Wait for Services**
   ```bash
   # Wait for all services to be healthy
   docker-compose ps
   
   # Check logs if any service fails
   docker-compose logs <service-name>
   ```

4. **Start Backend**
   ```bash
   cd ../backend/Industrialmonitor
   ./mvnw spring-boot:run
   ```

5. **Start Simulator**
   ```bash
   cd ../../simulator
   pip install -r requirements.txt
   python sensor_simulator.py
   ```

6. **Verify Setup**
   ```bash
   # Check API health
   curl http://localhost:8080/actuator/health
   
   # Check machines endpoint
   curl http://localhost:8080/api/machines
   ```

### Development Configuration

Create `infra/.env` file:
```env
# Database
POSTGRES_DB=machine_monitoring
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123

# Slack (optional for development)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Simulator
MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
PUBLISH_INTERVAL_MS=500
ANOMALY_INTERVAL_SECONDS=30

# Logging
LOG_LEVEL=DEBUG
```

### IDE Setup

**IntelliJ IDEA:**
1. Import Maven project from `backend/Industrialmonitor`
2. Set Project SDK to Java 8
3. Enable annotation processing for Lombok
4. Configure run configuration with active profile: `dev`

**VS Code:**
1. Install Java Extension Pack
2. Install Spring Boot Extension Pack
3. Open workspace from project root
4. Configure launch.json for debugging

## Production Environment

### Infrastructure Setup

**Option 1: Single Server Deployment**
```bash
# Create production directory
mkdir -p /opt/industrial-monitoring
cd /opt/industrial-monitoring

# Clone repository
git clone <repository-url> .

# Create production environment file
cp infra/.env.example infra/.env.prod
# Edit .env.prod with production values
```

**Option 2: Multi-Server Deployment**
- **App Server**: Backend application
- **Database Server**: PostgreSQL + Redis
- **Message Server**: Kafka + Zookeeper + MQTT
- **Load Balancer**: Nginx or HAProxy

### Production Configuration

Create `infra/.env.prod`:
```env
# Database - Use strong passwords
POSTGRES_DB=machine_monitoring
POSTGRES_USER=monitoring_user
POSTGRES_PASSWORD=<strong-password>

# Redis
REDIS_PASSWORD=<redis-password>

# Slack
SLACK_WEBHOOK_URL=<production-webhook-url>

# Security
JWT_SECRET=<jwt-secret-key>
API_KEY=<api-key>

# Performance
JVM_OPTS=-Xmx4g -Xms2g -XX:+UseG1GC
KAFKA_HEAP_OPTS=-Xmx2g -Xms1g

# Monitoring
ENABLE_METRICS=true
METRICS_ENDPOINT=/actuator/metrics
```

### SSL/TLS Configuration

**Generate SSL Certificates:**
```bash
# Using Let's Encrypt
certbot certonly --standalone -d your-domain.com

# Or use self-signed for internal use
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

**Configure Nginx Reverse Proxy:**
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /ws {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

## Docker Deployment

### Production Docker Compose

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    volumes:
      - zookeeper-data:/var/lib/zookeeper/data
      - zookeeper-logs:/var/lib/zookeeper/log
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_HEAP_OPTS: ${KAFKA_HEAP_OPTS:-Xmx1g -Xms1g}
    volumes:
      - kafka-data:/var/lib/kafka/data
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G

  mosquitto:
    image: eclipse-mosquitto:2.0
    ports:
      - "1883:1883"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - mosquitto-data:/mosquitto/data
      - mosquitto-logs:/mosquitto/log
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    depends_on:
      - postgres
      - redis
      - kafka
      - mosquitto
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/${POSTGRES_DB}
      SPRING_DATASOURCE_USERNAME: ${POSTGRES_USER}
      SPRING_DATASOURCE_PASSWORD: ${POSTGRES_PASSWORD}
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PORT: 6379
      SPRING_REDIS_PASSWORD: ${REDIS_PASSWORD}
      SPRING_KAFKA_BOOTSTRAP_SERVERS: kafka:29092
      MQTT_BROKER_URL: tcp://mosquitto:1883
      SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL}
      JAVA_OPTS: ${JVM_OPTS:-Xmx2g -Xms1g}
    volumes:
      - ./backend/logs:/app/logs
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  simulator:
    build:
      context: ./simulator
      dockerfile: Dockerfile
    depends_on:
      - mosquitto
    environment:
      MQTT_BROKER_HOST: mosquitto
      MQTT_BROKER_PORT: 1883
      PUBLISH_INTERVAL_MS: ${PUBLISH_INTERVAL_MS:-500}
      ANOMALY_INTERVAL_SECONDS: ${ANOMALY_INTERVAL_SECONDS:-30}
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M

volumes:
  zookeeper-data:
  zookeeper-logs:
  kafka-data:
  mosquitto-data:
  mosquitto-logs:
  postgres-data:
  redis-data:
```

### Production Dockerfile

Create `backend/Dockerfile.prod`:
```dockerfile
FROM maven:3.8-openjdk-8-slim AS build
WORKDIR /app
COPY pom.xml .
COPY src src
RUN mvn clean package -DskipTests -Pprod

FROM openjdk:8-jre-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### Deployment Commands

```bash
# Production deployment
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

# Scale backend instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Update application
docker-compose -f docker-compose.prod.yml pull backend
docker-compose -f docker-compose.prod.yml up -d backend

# View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

## Configuration

### Environment Variables

**Database Configuration:**
```env
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/machine_monitoring
SPRING_DATASOURCE_USERNAME=monitoring_user
SPRING_DATASOURCE_PASSWORD=secure_password
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
```

**Cache Configuration:**
```env
SPRING_REDIS_HOST=redis
SPRING_REDIS_PORT=6379
SPRING_REDIS_PASSWORD=redis_password
SPRING_REDIS_TIMEOUT=2000ms
```

**Kafka Configuration:**
```env
SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:29092
SPRING_KAFKA_CONSUMER_GROUP_ID=machine-monitoring
SPRING_KAFKA_CONSUMER_AUTO_OFFSET_RESET=earliest
```

**MQTT Configuration:**
```env
MQTT_BROKER_URL=tcp://mosquitto:1883
MQTT_CLIENT_ID=backend-subscriber
MQTT_TOPIC=machines/readings
```

**Application Configuration:**
```env
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_INDUSTRIALMONITOR=DEBUG
```

### Security Configuration

**Enable Security:**
```yaml
# application-prod.yml
security:
  enabled: true
  jwt:
    secret: ${JWT_SECRET}
    expiration: 86400 # 24 hours
  api:
    key: ${API_KEY}
    
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,info
  endpoint:
    health:
      show-details: when-authorized
```

### Performance Tuning

**JVM Options:**
```env
JAVA_OPTS=-Xmx4g -Xms2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication
```

**Database Tuning:**
```sql
-- PostgreSQL configuration
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '4GB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
SELECT pg_reload_conf();
```

**Kafka Tuning:**
```env
KAFKA_NUM_NETWORK_THREADS=8
KAFKA_NUM_IO_THREADS=8
KAFKA_SOCKET_SEND_BUFFER_BYTES=102400
KAFKA_SOCKET_RECEIVE_BUFFER_BYTES=102400
KAFKA_SOCKET_REQUEST_MAX_BYTES=104857600
```

## Monitoring & Maintenance

### Health Checks

**Application Health:**
```bash
# Check application health
curl http://localhost:8080/actuator/health

# Check detailed health
curl http://localhost:8080/actuator/health/db
curl http://localhost:8080/actuator/health/redis
curl http://localhost:8080/actuator/health/kafka
```

**Service Health:**
```bash
# Check all services
docker-compose ps

# Check service logs
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f kafka
```

### Metrics Collection

**Prometheus Configuration:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'industrial-monitoring'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/actuator/prometheus'
```

**Grafana Dashboard:**
- Import dashboard ID: 4701 (JVM Micrometer)
- Create custom dashboard for business metrics
- Set up alerts for critical thresholds

### Log Management

**Centralized Logging with ELK:**
```yaml
# docker-compose.logging.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    volumes:
      - ./logstash/config:/usr/share/logstash/pipeline
    ports:
      - "5000:5000"

  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
```

### Backup Strategy

**Database Backup:**
```bash
#!/bin/bash
# backup-db.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
DB_NAME="machine_monitoring"

# Create backup
docker exec postgres pg_dump -U admin $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete
```

**Volume Backup:**
```bash
#!/bin/bash
# backup-volumes.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"

# Backup Docker volumes
docker run --rm -v industrial-monitoring_postgres-data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/postgres_$DATE.tar.gz -C /data .
docker run --rm -v industrial-monitoring_kafka-data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/kafka_$DATE.tar.gz -C /data .
```

### Update Procedure

**Rolling Update:**
```bash
#!/bin/bash
# update.sh
set -e

echo "Starting rolling update..."

# Pull latest images
docker-compose -f docker-compose.prod.yml pull

# Update backend instances one by one
for i in {1..3}; do
    echo "Updating backend instance $i..."
    docker-compose -f docker-compose.prod.yml up -d --no-deps --scale backend=$((3-i+1)) backend
    sleep 30
    
    # Health check
    curl -f http://localhost:8080/actuator/health || exit 1
done

echo "Update completed successfully"
```

## Troubleshooting

### Common Issues

**Backend Won't Start:**
```bash
# Check logs
docker-compose logs backend

# Common causes:
# 1. Database connection failed
# 2. Kafka not ready
# 3. Port already in use
# 4. Configuration error

# Solutions:
docker-compose restart postgres
docker-compose restart kafka
netstat -tulpn | grep 8080
```

**High Memory Usage:**
```bash
# Check memory usage
docker stats

# Adjust JVM heap size
export JAVA_OPTS="-Xmx2g -Xms1g"
docker-compose restart backend
```

**Database Connection Pool Exhausted:**
```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

**Kafka Consumer Lag:**
```bash
# Check consumer lag
docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group machine-monitoring

# Reset consumer offset if needed
docker exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --group machine-monitoring --reset-offsets --to-earliest --topic sensor-readings --execute
```

### Performance Issues

**Slow Database Queries:**
```sql
-- Enable query logging
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

**High CPU Usage:**
```bash
# Check Java thread dump
docker exec backend jstack 1 > thread_dump.txt

# Check for GC issues
docker exec backend jstat -gc 1 5s
```

### Network Issues

**WebSocket Connection Problems:**
```bash
# Check WebSocket endpoint
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: test" http://localhost:8080/ws

# Check firewall rules
iptables -L -n | grep 8080
```

**MQTT Connection Issues:**
```bash
# Test MQTT connection
docker exec mosquitto mosquitto_pub -h localhost -t test -m "hello"
docker exec mosquitto mosquitto_sub -h localhost -t test

# Check MQTT logs
docker-compose logs mosquitto
```

## Scaling

### Horizontal Scaling

**Scale Backend Instances:**
```bash
# Scale to 5 instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=5

# Use load balancer
# nginx.conf
upstream backend {
    server localhost:8080;
    server localhost:8081;
    server localhost:8082;
}
```

**Scale Kafka:**
```yaml
# Add more Kafka brokers
kafka-2:
  image: confluentinc/cp-kafka:7.4.0
  environment:
    KAFKA_BROKER_ID: 2
    # ... other config
```

**Database Scaling:**
```yaml
# Add read replicas
postgres-replica:
  image: postgres:15
  environment:
    PGUSER: replicator
    POSTGRES_PASSWORD: replica_password
    PGPASSWORD: replica_password
  command: |
    bash -c "
    pg_basebackup -h postgres -D /var/lib/postgresql/data -U replicator -v -P -W
    echo 'standby_mode = on' >> /var/lib/postgresql/data/recovery.conf
    echo 'primary_conninfo = host=postgres port=5432 user=replicator' >> /var/lib/postgresql/data/recovery.conf
    postgres
    "
```

### Vertical Scaling

**Increase Resources:**
```yaml
# docker-compose.prod.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

**Optimize JVM:**
```env
JAVA_OPTS=-Xmx6g -Xms4g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication -XX:+OptimizeStringConcat
```

### Auto-Scaling with Docker Swarm

```yaml
# docker-stack.yml
version: '3.8'
services:
  backend:
    image: industrial-monitoring/backend:latest
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

Deploy with Docker Swarm:
```bash
docker swarm init
docker stack deploy -c docker-stack.yml industrial-monitoring
docker service scale industrial-monitoring_backend=5
```

---

This deployment guide provides comprehensive instructions for setting up the Industrial Machine Monitoring System in various environments. Follow the appropriate section based on your deployment needs and environment constraints.