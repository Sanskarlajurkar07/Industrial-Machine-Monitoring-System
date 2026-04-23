package com.industrialmonitor.industrialmonitor.repository;

import com.industrialmonitor.industrialmonitor.modal.Machine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MachineRepository  extends JpaRepository<Machine,String> {
}
