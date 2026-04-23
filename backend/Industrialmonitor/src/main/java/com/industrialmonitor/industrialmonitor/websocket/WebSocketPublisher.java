package com.industrialmonitor.industrialmonitor.websocket;

import com.industrialmonitor.industrialmonitor.modal.Alert;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class WebSocketPublisher {

    private final SimpMessagingTemplate messagingTemplate;

    public void publishReading(SensorReading reading) {
        messagingTemplate.convertAndSend("/topic/readings", reading);
    }

    public void publishAlert(Alert alert) {
        messagingTemplate.convertAndSend("/topic/alerts", alert);
    }
}