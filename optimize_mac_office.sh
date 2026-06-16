#!/usr/bin/env bash
# ==============================================================================
# Script Name : optimize_mac_office.sh
# Description : Optimize Microsoft Office for macOS (Disable Telemetry & Cloud)
# Author      : Harry DS Alsyundawy
# License     : MIT
# ==============================================================================
#
# This script disables telemetry and cloud-based features for Microsoft Office
# applications on macOS to enhance privacy and optimize resource usage.

set -euo pipefail

# --- Configurations ---
readonly PLISTS_TELEMETRY=(
    "com.microsoft.Word"
    "com.microsoft.Excel"
    "com.microsoft.Powerpoint"
    "com.microsoft.Outlook"
    "com.microsoft.onenote.mac"
    "com.microsoft.autoupdate2"
    "com.microsoft.Office365ServiceV2"
)

readonly PLISTS_CLOUD=(
    "com.microsoft.Word"
    "com.microsoft.Excel"
    "com.microsoft.Powerpoint"
)

# --- Functions ---
log_info() {
    printf "\e[1;34m[INFO]\e[0m %s\n" "$1"
}

log_success() {
    printf "\e[1;32m[SUCCESS]\e[0m %s\n" "$1"
}

log_error() {
    printf "\e[1;31m[ERROR]\e[0m %s\n" "$1" >&2
}

disable_telemetry() {
    log_info "Disabling Microsoft Office Telemetry..."
    local plist
    for plist in "${PLISTS_TELEMETRY[@]}"; do
        if defaults write "$plist" SendAllTelemetryEnabled -bool FALSE; then
            log_success "Disabled telemetry for $plist"
        else
            log_error "Failed to disable telemetry for $plist"
        fi
    done
}

disable_cloud_content() {
    log_info "Disabling Microsoft Office Cloud Content features..."
    local plist
    for plist in "${PLISTS_CLOUD[@]}"; do
        if defaults write "$plist" UseOnlineContent -integer 0; then
            log_success "Disabled cloud content for $plist"
        else
            log_error "Failed to disable cloud content for $plist"
        fi
    done
}

main() {
    echo "===================================================="
    echo "   Microsoft Office for macOS Optimizer Script      "
    echo "===================================================="
    
    disable_telemetry
    disable_cloud_content
    
    echo "===================================================="
    log_success "Optimization completed successfully."
}

main "$@"
