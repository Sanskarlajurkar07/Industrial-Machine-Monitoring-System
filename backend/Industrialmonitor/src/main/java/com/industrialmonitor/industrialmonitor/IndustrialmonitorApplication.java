package com.industrialmonitor.industrialmonitor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class IndustrialmonitorApplication {

    public static void main(String[] args) {
        SpringApplication.run(IndustrialmonitorApplication.class, args);
    }

}
