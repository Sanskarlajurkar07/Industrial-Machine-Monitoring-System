package com.industrialmonitor.industrialmonitor.repository;

import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface SensorReadingRepository extends JpaRepository<SensorReading, Long> {
    Page<SensorReading> findByMachineIdAndTimestampBetween(String machineId, LocalDateTime start, LocalDateTime end, Pageable pageable);
    Optional<SensorReading> findTopByMachineIdOrderByTimestampDesc(String machineId);
}
