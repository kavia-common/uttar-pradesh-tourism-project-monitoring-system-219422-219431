package com.uptourism.pms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Entry point for the UP Tourism Project Monitoring Backend application.
 * Exposes a simple root endpoint for quick health verification.
 */
@SpringBootApplication
public class ProjectMonitoringBackendApplication {

    // PUBLIC_INTERFACE
    public static void main(String[] args) {
        /**
         * This is the Spring Boot application entrypoint.
         * It starts the embedded server on the configured port (see application.properties).
         */
        SpringApplication.run(ProjectMonitoringBackendApplication.class, args);
    }

    @RestController
    static class RootController {
        // PUBLIC_INTERFACE
        @GetMapping("/")
        /** Basic liveness endpoint that returns a simple string response. */
        public String root() {
            return "UP Tourism Project Monitoring Backend OK";
        }
    }
}
