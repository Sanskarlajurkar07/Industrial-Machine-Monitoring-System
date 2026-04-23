package com.industrialmonitor.industrialmonitor.repository;

import com.industrialmonitor.industrialmonitor.modal.Alert;
import com.industrialmonitor.industrialmonitor.modal.AlertStatus;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlertRepository extends JpaRepository<Alert ,Long> {
    Optional<Alert> findByMachineIdAndRuleIdAndStatus(String machineId, Long ruleId, AlertStatus status);
    List<Alert> findByMachineIdAndStatus(String machineId, AlertStatus status);

    @Query("SELECT a FROM Alert a WHERE (:machineId IS NULL OR a.machineId = :machineId) " +
            "AND (:severity IS NULL OR a.severity = :severity) " +
            "AND (:status IS NULL OR a.status = :status)")
    Page<Alert> findByFilters(@Param("machineId") String machineId,
                              @Param("severity") String severity,
                              @Param("status") AlertStatus status,
                              Pageable pageable);
}
