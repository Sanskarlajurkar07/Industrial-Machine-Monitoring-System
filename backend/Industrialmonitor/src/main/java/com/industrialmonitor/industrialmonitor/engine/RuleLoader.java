package com.industrialmonitor.industrialmonitor.engine;

import com.industrialmonitor.industrialmonitor.modal.AlertRule;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import com.industrialmonitor.industrialmonitor.repository.AlertRuleRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.expression.Expression;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.expression.spel.support.StandardEvaluationContext;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;
import java.util.function.Function;

@Slf4j
@Component
@RequiredArgsConstructor
public class RuleLoader {
    private final AlertRuleRepository alertRuleRepository;
    private final List<BoundRule> compiledRules = new CopyOnWriteArrayList<>();
    private final ExpressionParser parser = new SpelExpressionParser();

    @PostConstruct
    public void init() {
        try {
            loadRules();
        } catch (Exception e) {
            log.warn("Failed to load rules during initialization, will retry later: {}", e.getMessage());
            // Don't fail application startup - rules will be loaded by scheduled task
        }
    }

    @Scheduled(fixedDelay = 60000)
    public void loadRules() {
        try {
            List<AlertRule> dbRules = alertRuleRepository.findByEnabledTrue();
            List<BoundRule> newCompiledRules = dbRules.stream()
                    .map(this::compileRule)
                    .collect(Collectors.toList());

            compiledRules.clear();
            compiledRules.addAll(newCompiledRules);
            log.info("Loaded {} active alert rules from database", compiledRules.size());
        } catch (Exception e) {
            log.error("Failed to load rules from database: {}", e.getMessage(), e);
        }
    }

    private BoundRule compileRule(AlertRule rule) {
        Expression expr = parser.parseExpression(rule.getCondition());
        Function<SensorReading, Boolean> lambda = reading -> {
            StandardEvaluationContext context = new StandardEvaluationContext(reading);
            Boolean result = expr.getValue(context, Boolean.class);
            return result != null && result;
        };
        return new BoundRule(lambda, rule);
    }

    public List<RuleEvaluationResult> evaluateAll(SensorReading reading) {
        return compiledRules.stream()
                .map(rule -> rule.evaluate(reading))
                .filter(RuleEvaluationResult::isTriggered)
                .collect(Collectors.toList());
    }
}
