package com.industrialmonitor.industrialmonitor.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.industrialmonitor.industrialmonitor.engine.RuleEngine;
import com.industrialmonitor.industrialmonitor.engine.RuleEvaluationResult;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import com.industrialmonitor.industrialmonitor.repository.SensorReadingRepository;
import com.industrialmonitor.industrialmonitor.service.AlertManager;
import com.industrialmonitor.industrialmonitor.service.CacheService;
import com.industrialmonitor.industrialmonitor.websocket.WebSocketPublisher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final ObjectMapper objectMapper;
    private final SensorReadingRepository sensorReadingRepository;
    private final CacheService cacheService;
    private final RuleEngine ruleEngine;
    private final AlertManager alertManager;
    private final WebSocketPublisher webSocketPublisher;

    @KafkaListener(topics = "${kafka.topics.sensor-readings}", groupId = "${spring.kafka.consumer.group-id}")
    public void consume(String message) {
        try {
            SensorReading reading = objectMapper.readValue(message, SensorReading.class);
            sensorReadingRepository.save(reading);
            cacheService.saveLatestReading(reading);

            List<RuleEvaluationResult> results = ruleEngine.evaluate(reading);
            alertManager.processViolatedRules(reading, results);
            alertManager.checkForResolution(reading);
            alertManager.updateMachineStatus(reading.getMachineId());

            webSocketPublisher.publishReading(reading);
            log.debug("Processed reading: {}", reading.getMachineId());
        } catch (Exception e) {
            log.error("Failed to process: {} | {}", message, e.getMessage());
        }
    }
}