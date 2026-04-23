package com.industrialmonitor.industrialmonitor.modal;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

import java.util.List;

@Entity
@Table(name = "machines")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Machine {
    
    @Id
    @Column(name = "id", length = 10)
    private String id;
    
    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private MachineStatus status;

    @Column(nullable = false)
    private String location;

    private LocalDate installationDate;

    @OneToMany
    @JoinColumn(name = "machine_id")
    @JsonIgnore
    private List<SensorReading> readings;

    @OneToMany(mappedBy = "machine")
    @JsonManagedReference
    private List<Alert> alerts;

}
