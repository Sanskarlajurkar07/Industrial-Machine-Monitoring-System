package com.industrialmonitor.industrialmonitor.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import com.industrialmonitor.industrialmonitor.repository.SensorReadingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class CacheService {
    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;
    private final SensorReadingRepository sensorReadingRepository;
    
    public void saveLatestReading(SensorReading reading) {
        try {
            String key = "machine:" + reading.getMachineId() + ":latest";
            String json = objectMapper.writeValueAsString(reading);
            redisTemplate.opsForValue().set(key, json, 60, TimeUnit.SECONDS);
        } catch (Exception e) {
            log.error("Failed to cache reading for {}", reading.getMachineId(), e);
        }
    }
    
    public Optional<SensorReading> getLatestReading(String machineId) {
        try {
            String key = "machine:" + machineId + ":latest";
            String json = redisTemplate.opsForValue().get(key);
            if (json != null) {
                return Optional.of(objectMapper.readValue(json, SensorReading.class));
            }
            return Optional.empty();
        } catch (Exception e) {
            log.warn("Cache read failed, falling back to DB", e);
            return sensorReadingRepository.findTopByMachineIdOrderByTimestampDesc(machineId);
        }
    }
}
