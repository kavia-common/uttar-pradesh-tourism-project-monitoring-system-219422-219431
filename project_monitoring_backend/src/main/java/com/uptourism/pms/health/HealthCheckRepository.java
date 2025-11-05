package com.uptourism.pms.health;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Repository for interacting with the minimal HealthCheckEntity.
 */
public interface HealthCheckRepository extends JpaRepository<HealthCheckEntity, Long> {
    // Intentionally empty; CRUD via JpaRepository
}
