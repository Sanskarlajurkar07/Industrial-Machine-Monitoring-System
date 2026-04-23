package com.industrialmonitor.industrialmonitor.controller;

import com.industrialmonitor.industrialmonitor.exception.ResourceNotFoundException;
import com.industrialmonitor.industrialmonitor.modal.Alert;
import com.industrialmonitor.industrialmonitor.modal.AlertStatus;
import com.industrialmonitor.industrialmonitor.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
public class AlertController {

    private final AlertRepository alertRepository;

    @GetMapping
    public Page<Alert> getAlerts(
            @RequestParam(required = false) String machineId,
            @RequestParam(required = false) String severity,
            @RequestParam(required = false) AlertStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {

        return alertRepository.findByFilters(machineId, severity, status, PageRequest.of(page, size));
    }

    @PutMapping("/{id}/resolve")
    public Alert resolveAlert(@PathVariable Long id) {
        Alert alert = alertRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Alert not found with id " + id));

        alert.setStatus(AlertStatus.RESOLVED);
        alert.setResolvedAt(LocalDateTime.now());
        return alertRepository.save(alert);
    }
}