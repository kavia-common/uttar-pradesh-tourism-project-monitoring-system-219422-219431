#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tour-monitoring-system-219422-219431/project_monitoring_backend"
cd "$WORKSPACE"
if ! command -v mvn >/dev/null 2>&1; then echo "ERROR: mvn not found" >&2; exit 301; fi
export MAVEN_OPTS="-Djava.awt.headless=true -Xms64m -Xmx512m ${MAVEN_OPTS:-}"
if ! mvn -B test -DskipITs; then
  echo "ERROR: mvn test failed" >&2
  if [ -d target/surefire-reports ]; then
    echo "--- surefire xml summaries ---" >&2
    for f in target/surefire-reports/*.xml; do [ -f "$f" ] || continue; if command -v xmllint >/dev/null 2>&1; then xmllint --format "$f" 2>/dev/null | sed -n '1,200p' || sed -n '1,200p' "$f"; else sed -n '1,200p' "$f" || true; fi; done
  fi
  exit 302
fi
