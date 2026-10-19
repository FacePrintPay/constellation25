#!/usr/bin/env bash
################################################################################
# Constellation25 Health Check & Status Monitor
################################################################################

set -euo pipefail

log_status() {
    echo "✓ $1"
}

log_fail() {
    echo "✗ $1"
}

check_service() {
    local url=$1
    local timeout=5
    
    if curl -s -m "$timeout" "$url" > /dev/null 2>&1; then
        log_status "Service up: $url"
        return 0
    else
        log_fail "Service down: $url"
        return 1
    fi
}

main() {
    echo "╔════════════════════════════════════════╗"
    echo "║  Constellation25 Health Check          ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    local all_pass=true
    
    # Check core services
    echo "Core Services:"
    check_service "http://localhost:8000/health" || all_pass=false
    check_service "http://localhost:3005/health" || all_pass=false
    
    # Check agent status
    echo ""
    echo "Agent Status:"
    if [ -f ".c25/agent_registry.json" ]; then
        log_status "Agent registry found"
    else
        log_fail "Agent registry not found"
        all_pass=false
    fi
    
    # Check deployment manifest
    echo ""
    echo "Deployment Status:"
    if [ -f "DEPLOYMENT_MANIFEST.json" ]; then
        log_status "Deployment manifest present"
    else
        log_fail "Deployment manifest missing"
        all_pass=false
    fi
    
    echo ""
    if [ "$all_pass" = true ]; then
        echo "✓ All systems operational"
        exit 0
    else
        echo "✗ Some systems offline"
        exit 1
    fi
}

main "$@"
