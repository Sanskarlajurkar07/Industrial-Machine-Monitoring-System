package com.industrialmonitor.industrialmonitor.engine;

import com.industrialmonitor.industrialmonitor.modal.AlertRule;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;

import java.util.function.Function;

public class BoundRule {
    private final Function<SensorReading, Boolean> evaluator;
    private final AlertRule dbRule;

    public BoundRule(Function<SensorReading, Boolean> evaluator, AlertRule dbRule) {
        this.evaluator = evaluator;
        this.dbRule = dbRule;
    }
    
    public RuleEvaluationResult evaluate(SensorReading reading) {
        boolean triggered = evaluator.apply(reading);
        RuleEvaluationResult result = new RuleEvaluationResult();
        result.setTriggered(triggered);
        result.setRuleId(dbRule.getId());
        result.setRuleName(dbRule.getName());
        result.setSeverity(dbRule.getSeverity());
        result.setMessage(dbRule.getMessage());

        // Simple extraction for demonstration
        if (dbRule.getCondition().contains("temperature")) {
            result.setParameter("temperature");
            result.setActualValue(reading.getTemperature() != null ? reading.getTemperature() : 0.0);
        } else if (dbRule.getCondition().contains("vibration")) {
            result.setParameter("vibration");
            result.setActualValue(reading.getVibration() != null ? reading.getVibration() : 0.0);
        } else if (dbRule.getCondition().contains("pressure")) {
            result.setParameter("pressure");
            result.setActualValue(reading.getPressure() != null ? reading.getPressure() : 0.0);
        } else if (dbRule.getCondition().contains("rpm")) {
            result.setParameter("rpm");
            result.setActualValue(reading.getRpm() != null ? reading.getRpm() : 0.0);
        }

        return result;
    }
}
