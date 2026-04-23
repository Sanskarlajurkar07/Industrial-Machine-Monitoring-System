package com.industrialmonitor.industrialmonitor.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaConfig {

    @Value("${kafka.topics.sensor-readings}")
    private String topicName;

    @Bean
    public NewTopic sensorReadingsTopic() {
        return TopicBuilder.name(topicName)
                .partitions(3)
                .replicas(1)
                .config("retention.ms", String.valueOf(7 * 24 * 60 * 60 * 1000L)) // 7 days
                .build();
    }
}