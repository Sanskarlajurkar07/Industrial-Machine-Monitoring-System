package com.industrialmonitor.industrialmonitor.controller;

import com.industrialmonitor.industrialmonitor.modal.Machine;
import com.industrialmonitor.industrialmonitor.modal.SensorReading;
import com.industrialmonitor.industrialmonitor.repository.MachineRepository;
import com.industrialmonitor.industrialmonitor.repository.SensorReadingRepository;
import com.industrialmonitor.industrialmonitor.service.CacheService;
import lombok.RequiredArgsConstructor;
import com.industrialmonitor.industrialmonitor.exception.ResourceNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/machines")
@RequiredArgsConstructor
public class MachineController {

    private final MachineRepository machineRepository;
    private final SensorReadingRepository sensorReadingRepository;
    private final CacheService cacheService;

    @GetMapping
    public List<Machine> getAllMachines() {
        return machineRepository.findAll();
    }

    @GetMapping("/{id}")
    public Map<String, Object> getMachineById(@PathVariable String id) {
        Machine machine = machineRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Machine not found with id " + id));

        SensorReading latestReading = cacheService.getLatestReading(id).orElse(null);

        Map<String, Object> response = new HashMap<>();
        response.put("machine", machine);
        response.put("latestReading", latestReading);
        return response;
    }

    @GetMapping("/{id}/readings")
    public Page<SensorReading> getMachineReadings(
            @PathVariable String id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size) {

        if (!machineRepository.existsById(id)) {
            throw new ResourceNotFoundException("Machine not found with id " + id);
        }

        return sensorReadingRepository.findByMachineIdAndTimestampBetween(id, start, end, PageRequest.of(page, size));
    }
}