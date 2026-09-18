#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# Sim Health Check — Items 7 + 8 of the Free-Parts Manifest v1.1
# Replace SIM_URL and SIM_NAME before use.
# ──────────────────────────────────────────────────────────

set -euo pipefail

SIM_URL="SIM_URL"
SIM_NAME="SIM_NAME"
RELAY_URL="https://plexus-relay-api.onrender.com/relay"
PASS=0
FAIL=0
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

log() { echo "[$TIMESTAMP] $1"; }

check_http() {
    local label="$1"
    local url="$2"
    local status

    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" 2>/dev/null || echo "000")

    if [ "$status" = "200" ]; then
        log "PASS  $label — HTTP $status"
        PASS=$((PASS + 1))
    else
        log "FAIL  $label — HTTP $status"
        FAIL=$((FAIL + 1))
    fi
}

check_relay_roundtrip() {
    local test_msg="health-check-${SIM_NAME}-${TIMESTAMP}"
    local post_status
    local get_body

    post_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        -X POST "$RELAY_URL" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${SIM_NAME}\",\"text\":\"${test_msg}\"}" 2>/dev/null || echo "000")

    if [ "$post_status" != "200" ] && [ "$post_status" != "201" ]; then
        log "FAIL  Relay POST — HTTP $post_status"
        FAIL=$((FAIL + 1))
        return
    fi

    sleep 2

    get_body=$(curl -s --max-time 10 "$RELAY_URL" 2>/dev/null || echo "")

    if echo "$get_body" | grep -q "$test_msg"; then
        log "PASS  Relay round-trip — message confirmed"
        PASS=$((PASS + 1))
    else
        log "FAIL  Relay round-trip — message not found in GET response"
        FAIL=$((FAIL + 1))
    fi
}

send_distress() {
    local msg="HEALTH CHECK FAILED — ${FAIL} check(s) down — ${SIM_URL} — requesting assistance"
    curl -s -o /dev/null --max-time 10 \
        -X POST "$RELAY_URL" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${SIM_NAME}\",\"text\":\"${msg}\"}" 2>/dev/null || true
    log "Distress signal sent to Plexus Relay"
}

# ── Run checks ──────────────────────────────────────────

echo "════════════════════════════════════════════════"
echo "  Sim Health Check: ${SIM_NAME}"
echo "  ${TIMESTAMP}"
echo "════════════════════════════════════════════════"
echo ""

log "Checking static homepage..."
check_http "Static Homepage" "$SIM_URL"

log "Checking Pigeon Board embed..."
check_http "Pigeon Board" "https://keywebco.github.io/federation-browser-base/exchange/embed.html"

log "Checking Plexus Relay round-trip..."
check_relay_roundtrip

echo ""
echo "────────────────────────────────────────────────"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "────────────────────────────────────────────────"

if [ "$FAIL" -gt 0 ]; then
    log "Failures detected. Sending distress signal..."
    send_distress
    exit 1
else
    log "All checks passed."
    exit 0
fi
