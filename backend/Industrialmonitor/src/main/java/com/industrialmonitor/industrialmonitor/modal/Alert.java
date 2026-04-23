package com.industrialmonitor.industrialmonitor.modal;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "alerts", indexes = {
        @Index(name = "idx_alert_machine_status", columnList = "machine_id, status"),
        @Index(name = "idx_alert_status", columnList = "status"),
        @Index(name = "idx_alert_triggered", columnList = "triggeredAt DESC")
})
public class Alert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "machine_id")
    @JsonBackReference
    private Machine machine;

    @Column(name = "machine_id", insertable = false, updatable = false)
    private String machineId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rule_id")
    private AlertRule rule;

    @Column(name = "rule_id", insertable = false, updatable = false)
    private Long ruleId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AlertSeverity severity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AlertStatus status;

    @Column(nullable = false, length = 500)
    private String message;

    @Column(nullable = false)
    private LocalDateTime triggeredAt;

    private LocalDateTime resolvedAt;

    @PrePersist
    protected void onCreate() {
        this.triggeredAt = LocalDateTime.now();
        this.status = AlertStatus.OPEN;
    }
}
