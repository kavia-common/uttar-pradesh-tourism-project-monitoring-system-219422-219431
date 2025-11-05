package com.uptourism.pms.health;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Exposes a simple health endpoint that validates database connectivity.
 */
@RestController
public class HealthController {

    private final JdbcTemplate jdbcTemplate;
    private final HealthCheckRepository repository;

    @Autowired
    public HealthController(JdbcTemplate jdbcTemplate, HealthCheckRepository repository) {
        this.jdbcTemplate = jdbcTemplate;
        this.repository = repository;
    }

    // PUBLIC_INTERFACE
    @GetMapping("/health/db")
    /**
     * Database connectivity health endpoint.
     * Performs a "SELECT 1" using JdbcTemplate and tries a minimal JPA write/read using HealthCheckEntity.
     *
     * Returns:
     *  - status: "UP" or "DOWN"
     *  - selectOne: result of SELECT 1 (if successful)
     *  - jpaWriteRead: "OK" if insert+read succeeded
     *  - error: error message in case of failure
     */
    public Map<String, Object> dbHealth() {
        Map<String, Object> result = new HashMap<>();
        try {
            Integer one = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            result.put("selectOne", one);

            // Minimal JPA write+read to assert ORM works
            HealthCheckEntity saved = repository.save(new HealthCheckEntity("OK"));
            boolean exists = repository.findById(saved.getId()).isPresent();
            result.put("jpaWriteRead", exists ? "OK" : "FAILED");

            result.put("status", "UP");
        } catch (DataAccessException dae) {
            result.put("status", "DOWN");
            result.put("error", dae.getMessage());
        } catch (Exception e) {
            result.put("status", "DOWN");
            result.put("error", e.getMessage());
        }
        return result;
    }
}
