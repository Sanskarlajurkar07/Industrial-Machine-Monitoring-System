package com.industrialmonitor.industrialmonitor.service;

import com.industrialmonitor.industrialmonitor.modal.Alert;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class SlackNotificationService {
    
    private final RestTemplate restTemplate;

    @Value("${slack.webhook.url:}")
    private String webhookUrl;

    public void sendNotification(Alert alert) {
        CompletableFuture.runAsync(() -> {
                    try {
                        if (webhookUrl == null || webhookUrl.isEmpty()) return;

                        String payload = String.format(
                                "{\"text\": \"🚨 CRITICAL Alert\", \"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Machine:* %s\\n*Severity:* %s\\n*Message:* %s\\n*Time:* %s\"}}]}",
                                alert.getMachineId(), alert.getSeverity(), alert.getMessage(), alert.getTriggeredAt()
                        );

                        HttpHeaders headers = new HttpHeaders();
                        headers.setContentType(MediaType.APPLICATION_JSON);
                        HttpEntity<String> request = new HttpEntity<>(payload, headers);

                        restTemplate.postForEntity(webhookUrl, request, String.class);
                        log.info("Slack notification sent for alert {}", alert.getId());
                    } catch (Exception e) {
                        log.error("Slack failed for alert {}: {}", alert.getId(), e.getMessage());
                    }
                }).orTimeout(5, TimeUnit.SECONDS)
                .exceptionally(ex -> {
                    log.error("Slack timeout", ex);
                    return null;
                });
    }
}