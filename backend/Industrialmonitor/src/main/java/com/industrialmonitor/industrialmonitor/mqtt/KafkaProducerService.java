package com.industrialmonitor.industrialmonitor.mqtt;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

@Slf4j
@Service
@RequiredArgsConstructor
public class KafkaProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    private final Queue<SensorReading> buffer = new ConcurrentLinkedQueue<>();
    private static final int MAX_BUFFER_SIZE = 1000;

    @Value("${kafka.topics.sensor-readings}")
    private String topicName;

    public void sendMessage(SensorReading reading) {
        try {
            String json = objectMapper.writeValueAsString(reading);
            kafkaTemplate.send(topicName, reading.getMachineId(), json);
        } catch (Exception e) {
            if (buffer.size() < MAX_BUFFER_SIZE) {
                buffer.offer(reading);
                log.error("Kafka unavailable, buffered message for {}", reading.getMachineId());
            } else {
                log.error("Buffer full, dropping message for {}", reading.getMachineId());
            }
        }
    }

    @Scheduled(fixedDelay = 5000)
    public void retryBuffered() {
        if (!buffer.isEmpty()) {
            log.info("Retrying {} buffered messages", buffer.size());
            if (buffer.size() > 800) {
                log.error("Buffer at {}% capacity", buffer.size() / 10);
            }
            while (!buffer.isEmpty()) {
                SensorReading r = buffer.poll();
                if (r != null) {
                    sendMessage(r);
                }
            }
        }
    }
}