package com.industrialmonitor.industrialmonitor.modal;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@JsonIgnoreProperties(ignoreUnknown = true)
@Table(name ="sensor_readings" ,indexes={
        @Index(name="idx_reading_machine_id",  columnList = "machine_id"),
        @Index(name="idx_reading_timestamp", columnList = "timestamp")
})
public class SensorReading {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private  Long id;

    // Field for JSON deserialization and database operations
    @JsonProperty("machineId")
    @Column(name = "machine_id", nullable = false)
    private String machineId;

    // Transient field for JSON deserialization only
    @JsonProperty("machineName")
    @Transient
    private String machineName;

    @Column(nullable = false)
    private Double temperature;

    @Column(nullable = false)
    private Double vibration;

    @Column(nullable = false)
    private Integer rpm;

    @Column(nullable = false)
    private Double pressure;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
