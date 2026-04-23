package com.industrialmonitor.industrialmonitor.engine;

import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RuleEngine {

    private final RuleLoader ruleLoader;

    public List<RuleEvaluationResult> evaluate(SensorReading reading) {
        long startTime = System.currentTimeMillis();

        List<RuleEvaluationResult> results = ruleLoader.evaluateAll(reading);

        long duration = System.currentTimeMillis() - startTime;
        if (duration > 50) {
            log.warn("Rule evaluation took {}ms for machine {}", duration, reading.getMachineId());
        }

        return results;
    }}
