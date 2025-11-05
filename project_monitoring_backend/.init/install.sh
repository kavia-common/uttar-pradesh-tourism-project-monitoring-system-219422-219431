#!/usr/bin/env bash
set -euo pipefail
# Install and validate JDK (>=17) and Maven; persist environment
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-project-monitoring-system-219422-219431/project_monitoring_backend"
MIN_JAVA=17
SPRING_BOOT_VERSION="${SPRING_BOOT_VERSION:-3.1.4}"
warn_java21=0
case "$SPRING_BOOT_VERSION" in 3.2.*|3.3.*|4.*) warn_java21=1;; esac
err(){ echo "ERROR: $*" >&2; }
check_net(){ curl -sSfI https://repo1.maven.org/ >/dev/null 2>&1; }
# detect java major
java_major=0
if command -v javac >/dev/null 2>&1; then ver=$(javac -version 2>&1 || true); java_major=$(echo "$ver" | sed -E 's/.* ([0-9]+)(\..*)?/\1/' || true); fi
if [ -z "${java_major:-}" ] || [ "$java_major" -eq 0 ]; then
  if command -v java >/dev/null 2>&1; then ver=$(java -version 2>&1 | sed -n '1p' || true); java_major=$(echo "$ver" | sed -E 's/.*"?([0-9]+)(\..*)?"?.*/\1/' || true); fi
fi
# detect maven (require >=3.6)
mvn_ok=0
if command -v mvn >/dev/null 2>&1; then mvn_ver=$(mvn -v 2>/dev/null | head -n1 || true); mvn_major=$(echo "$mvn_ver" | sed -E 's/.* ([0-9]+)\.([0-9]+)\.([0-9]+).*/\1/' || true); mvn_minor=$(echo "$mvn_ver" | sed -E 's/.* ([0-9]+)\.([0-9]+)\.([0-9]+).*/\2/' || true); if [ -n "${mvn_major}" ] && { [ "$mvn_major" -gt 3 ] || { [ "$mvn_major" -eq 3 ] && [ "${mvn_minor:-0}" -ge 6 ]; }; }; then mvn_ok=1; fi; fi
java_ok=0
if [ -n "${java_major:-}" ] && [ "$java_major" -ge "$MIN_JAVA" ]; then java_ok=1; fi
if [ "$java_ok" -eq 1 ] && [ "$mvn_ok" -eq 1 ]; then :; else
  if ! check_net; then err "Network unreachable; cannot apt install required packages. Provide openjdk and maven or set JAVA_HOME/MAVEN_HOME manually."; exit 101; fi
  sudo apt-get update -q && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-17-jdk maven libxml2-utils >/dev/null || { err "apt-get install failed"; exit 102; }
fi
# revalidate
if ! command -v java >/dev/null 2>&1; then err "java not found after install"; exit 103; fi
if ! command -v mvn >/dev/null 2>&1; then err "mvn not found after install"; exit 104; fi
compute_java_home(){
  if command -v javac >/dev/null 2>&1; then bin=$(readlink -f "$(command -v javac)") || true; else bin=$(readlink -f "$(command -v java)") || true; fi
  cand=""
  if [ -n "$bin" ]; then cand=$(dirname "$(dirname "$bin")"); fi
  if [ -x "${cand:-}/bin/java" ]; then echo "$cand"; return 0; fi
  for d in /usr/lib/jvm/java-*-openjdk* /usr/lib/jvm/jdk* /usr/lib/jvm/*; do
    [ -d "$d" ] || continue
    if [ -x "$d/bin/java" ]; then echo "$d"; return 0; fi
  done
  return 1
}
if ! JAVA_HOME_DIR=$(compute_java_home); then err "Could not determine JAVA_HOME; please set JAVA_HOME to a JDK 17+ path."; exit 105; fi
if [ ! -x "${JAVA_HOME_DIR}/bin/java" ]; then err "Computed JAVA_HOME (${JAVA_HOME_DIR}) lacks executable bin/java"; exit 106; fi
if command -v mvn >/dev/null 2>&1; then MVN_BIN=$(readlink -f "$(command -v mvn)" || true); MAVEN_HOME_DIR=""; if [ -n "$MVN_BIN" ]; then MAVEN_HOME_DIR=$(dirname "$(dirname "$MVN_BIN")"); fi; else MAVEN_HOME_DIR=""; fi
PROFILE_FILE=/etc/profile.d/java_maven.sh
# Idempotent write: write a temp file then move into place under sudo
TMPFILE=$(mktemp)
cat > "$TMPFILE" <<EOF
# Auto-generated: expose JAVA_HOME and MAVEN_HOME
export JAVA_HOME='${JAVA_HOME_DIR}'
if ! echo "\$PATH" | /bin/grep -q "${JAVA_HOME_DIR}/bin"; then
  export PATH='${JAVA_HOME_DIR}/bin':"\$PATH"
fi
export MAVEN_HOME='${MAVEN_HOME_DIR:-}'
if [ -n "\$MAVEN_HOME" ] && ! echo "\$PATH" | /bin/grep -q "\$MAVEN_HOME/bin"; then
  export PATH="\$MAVEN_HOME/bin:\$PATH"
fi
EOF
sudo mv "$TMPFILE" "$PROFILE_FILE"
sudo chmod 0755 "$PROFILE_FILE" || true
# source for current session if readable
if [ -r "$PROFILE_FILE" ]; then # shellcheck disable=SC1090
  source "$PROFILE_FILE" || true
fi
# ensure workspace exists
mkdir -p "$WORKSPACE"
# Print minimal validations
java -version 2>&1 | sed -n '1p'
mvn -v | sed -n '1p'
# warn about headless fallback if spring requires java21
if [ "$warn_java21" -eq 1 ] && [ "${java_major:-0}" -lt 21 ]; then echo "WARNING: SPRING_BOOT_VERSION=${SPRING_BOOT_VERSION} may require Java 21+. Current Java major=${java_major}." >&2; fi
exit 0
