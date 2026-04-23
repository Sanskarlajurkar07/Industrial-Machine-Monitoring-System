package com.industrialmonitor.industrialmonitor.mqtt;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class MqttSubscriberService {

    @Value("${mqtt.broker.url}")
    private String brokerUrl;

    @Value("${mqtt.broker.client-id}")
    private String clientId;

    @Value("${mqtt.broker.topic}")
    private String topic;

    private final KafkaProducerService kafkaProducerService;
    private final ObjectMapper objectMapper;
    private MqttClient mqttClient;

    @PostConstruct
    public void connect() {
        try {
            mqttClient = new MqttClient(brokerUrl, clientId, new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setAutomaticReconnect(true);
            options.setCleanSession(true);

            mqttClient.setCallback(new MqttCallback() {
                @Override
                public void connectionLost(Throwable cause) {
                    log.warn("MQTT connection lost: {}", cause.getMessage());
                    reconnect();
                }

                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    String payload = new String(message.getPayload());
                    try {
                        SensorReading reading = objectMapper.readValue(payload, SensorReading.class);
                        kafkaProducerService.sendMessage(reading);
                    } catch (JsonProcessingException e) {
                        log.error("Invalid JSON: {}", payload);
                    }
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    // no-op
                }
            });

            mqttClient.connect(options);
            mqttClient.subscribe(topic, 1);
            log.info("Connected to MQTT broker at {} and subscribed to {}", brokerUrl, topic);

        } catch (MqttException e) {
            log.error("Failed to connect to MQTT broker", e);
            reconnect();
        }
    }

    private void reconnect() {
        int backoff = 1000;
        int maxBackoff = 30000;
        while (!mqttClient.isConnected()) {
            try {
                Thread.sleep(backoff);
                log.info("Attempting MQTT reconnect...");
                mqttClient.reconnect();
                log.info("Successfully reconnected to MQTT broker");
            } catch (Exception e) {
                log.error("Reconnect failed. Retrying...");
                backoff = Math.min(backoff * 2, maxBackoff);
            }
        }
    }
}