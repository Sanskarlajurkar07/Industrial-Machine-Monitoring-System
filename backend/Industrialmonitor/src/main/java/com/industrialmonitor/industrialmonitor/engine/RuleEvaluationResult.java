package com.industrialmonitor.industrialmonitor.engine;

import com.industrialmonitor.industrialmonitor.modal.AlertSeverity;
import lombok.Data;

@Data
public class RuleEvaluationResult {
    private boolean triggered;
    private Long ruleId;
    private String ruleName;
    private AlertSeverity severity;
    private String message;
    private String parameter;
    private double actualValue;
}
