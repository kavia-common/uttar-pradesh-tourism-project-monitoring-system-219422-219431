# UP Tourism Project Monitoring Backend

Spring Boot service (port 3001) connected to PostgreSQL using Spring Data JPA.

## Running

- Local/Preview:
  - Using Procfile or package.json scripts:
    - `mvn -DskipTests spring-boot:run`
    - or `npm start`
  - Docker:
    - Build: `docker build -t pms-backend .`
    - Run: `docker run --rm -p 3001:3001 --env-file .env pms-backend`

The server listens on port `3001`.

## Required Environment Variables

Do NOT hardcode secrets. Configure via environment variables:

- `DB_HOST` (default: `project_monitoring_database`)
- `DB_PORT` (default: `5432`)
- `DB_NAME` (default: `uptourism_pms`)
- `DB_USER` (no default; must be set)
- `DB_PASSWORD` (no default; must be set)

Optional:
- `JPA_DDL_AUTO` (default: `update`)
- `DB_POOL_MAX_SIZE` (default: `10`)
- `DB_POOL_MIN_IDLE` (default: `2`)
- `DB_CONN_TIMEOUT_MS` (default: `30000`)

If running against the shared database container, ensure the service name `project_monitoring_database` resolves (Docker Compose/Kubernetes).

## Health Checks

- Liveness: `GET /` -> "UP Tourism Project Monitoring Backend OK"
- DB Health: `GET /health/db` -> Runs `SELECT 1` and a minimal JPA write/read.
- Actuator Health: `GET /actuator/health` (exposed) shows aggregated health including database when configured.

## Notes

- Hibernate dialect is set to PostgreSQL.
- Schema strategy defaults to `update` for development convenience. Use `validate` plus Flyway/Liquibase for production.
- A minimal entity `HealthCheckEntity` ensures schema presence and validates ORM.
