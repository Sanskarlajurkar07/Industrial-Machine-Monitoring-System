package com.industrialmonitor.industrialmonitor.service;

import com.industrialmonitor.industrialmonitor.engine.RuleEvaluationResult;
import com.industrialmonitor.industrialmonitor.modal.*;
import com.industrialmonitor.industrialmonitor.repository.AlertRepository;
import com.industrialmonitor.industrialmonitor.repository.AlertRuleRepository;
import com.industrialmonitor.industrialmonitor.repository.MachineRepository;
import com.industrialmonitor.industrialmonitor.websocket.WebSocketPublisher;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AlertManager {
    private final AlertRepository alertRepository;
    private final AlertRuleRepository ruleRepository;
    private final MachineRepository machineRepository;
    private final SlackNotificationService notificationService;
    private final WebSocketPublisher webSocketPublisher;
    @Transactional
    public void processViolatedRules(SensorReading reading, List<RuleEvaluationResult> results) {
        for (RuleEvaluationResult result : results) {
            Optional<Alert> existingAlert = alertRepository.findByMachineIdAndRuleIdAndStatus(
                    reading.getMachineId(), result.getRuleId(), AlertStatus.OPEN);

            if (!existingAlert.isPresent()) {
                Machine machine = machineRepository.findById(reading.getMachineId())
                        .orElseThrow(() -> new RuntimeException("Machine not found"));
                AlertRule rule = ruleRepository.findById(result.getRuleId())
                        .orElseThrow(() -> new RuntimeException("Rule not found"));

                Alert alert = new Alert();
                alert.setMachine(machine);
                alert.setRule(rule);
                alert.setSeverity(result.getSeverity());
                alert.setMessage(result.getMessage());
                alert = alertRepository.save(alert);

                if (alert.getSeverity() == AlertSeverity.CRITICAL) {
                    notificationService.sendNotification(alert);
                }
                webSocketPublisher.publishAlert(alert);
            }
        }
    }

    @Transactional
    public void checkForResolution(SensorReading reading) {
        List<Alert> openAlerts = alertRepository.findByMachineIdAndStatus(reading.getMachineId(), AlertStatus.OPEN);

        for (Alert alert : openAlerts) {
            AlertRule rule = ruleRepository.findById(alert.getRuleId()).orElse(null);
            if (rule != null) {
                // We re-evaluate simple condition logic here or assume RuleEngine handles complete matching
                // For a robust system, we rebuild the SpEL context.
                // Since this uses the same logic, we'll mimic the evaluation
                org.springframework.expression.ExpressionParser parser = new org.springframework.expression.spel.standard.SpelExpressionParser();
                org.springframework.expression.Expression expr = parser.parseExpression(rule.getCondition());
                org.springframework.expression.spel.support.StandardEvaluationContext context = new org.springframework.expression.spel.support.StandardEvaluationContext(reading);
                Boolean isStillTriggered = expr.getValue(context, Boolean.class);

                if (isStillTriggered != null && !isStillTriggered) {
                    alert.setStatus(AlertStatus.RESOLVED);
                    alert.setResolvedAt(LocalDateTime.now());
                    alertRepository.save(alert);
                    webSocketPublisher.publishAlert(alert);
                }
            }
        }
    }

    @Transactional
    public void updateMachineStatus(String machineId) {
        List<Alert> openAlerts = alertRepository.findByMachineIdAndStatus(machineId, AlertStatus.OPEN);
        long criticalCount = openAlerts.stream().filter(a -> a.getSeverity() == AlertSeverity.CRITICAL).count();
        long warningCount = openAlerts.stream().filter(a -> a.getSeverity() == AlertSeverity.WARNING).count();

        machineRepository.findById(machineId).ifPresent(machine -> {
            if (criticalCount > 0) {
                machine.setStatus(MachineStatus.CRITICAL);
            } else if (warningCount > 0) {
                machine.setStatus(MachineStatus.WARNING);
            } else {
                machine.setStatus(MachineStatus.NORMAL);
            }
            machineRepository.save(machine);
        });
    }
}

