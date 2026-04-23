package com.industrialmonitor.industrialmonitor.controller;

import com.industrialmonitor.industrialmonitor.modal.AlertStatus;
import com.industrialmonitor.industrialmonitor.modal.Machine;
import com.industrialmonitor.industrialmonitor.repository.AlertRepository;
import com.industrialmonitor.industrialmonitor.repository.MachineRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final MachineRepository machineRepository;
    private final AlertRepository alertRepository;

    @GetMapping("/summary")
    public Map<String, Object> getSummary() {
        List<Machine> machines = machineRepository.findAll();
        long totalMachines = machines.size();

        Map<String, Long> machinesByStatus = machines.stream()
                .collect(Collectors.groupingBy(m -> m.getStatus().name(), Collectors.counting()));

        List<com.industrialmonitor.industrialmonitor.modal.Alert> activeAlertsList = alertRepository.findAll().stream()
                .filter(a -> a.getStatus() == AlertStatus.OPEN)
                .collect(Collectors.toList());

        long activeAlerts = activeAlertsList.size();

        Map<String, Long> alertsBySeverity = activeAlertsList.stream()
                .collect(Collectors.groupingBy(a -> a.getSeverity().name(), Collectors.counting()));

        Map<String, Object> summary = new HashMap<>();
        summary.put("totalMachines", totalMachines);
        summary.put("activeAlerts", activeAlerts);
        summary.put("machinesByStatus", machinesByStatus);
        summary.put("alertsBySeverity", alertsBySeverity);

        return summary;
    }
}