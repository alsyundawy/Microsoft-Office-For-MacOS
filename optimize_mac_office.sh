#!/usr/bin/env bash
# ==============================================================================
# Script Name : optimize_mac_office.sh
# Description : Optimize Microsoft Office for macOS (Disable Telemetry & Cloud)
# Author      : Harry DS Alsyundawy
# License     : MIT
# Version     : 1.2.0
# ==============================================================================
#
# DOCNOTE:
#   This script is designed to run locally on macOS by the currently logged-in
#   user. Do not execute it using sudo/root, as that will write preferences to
#   the root user profile instead of the target user profile.
#
# CHANGELOG:
#   v1.2.0 (2026-08-14):
#     - Optimized logging mechanism with automatic TTY color detection and
#       POSIX-compliant '\033' ANSI escape sequences.
#     - Refactored EXIT/signal trap handling with idempotent trap unsetting to
#       prevent potential recursive subshell exits.
#     - Extracted connected experience preference keys into a dedicated readonly
#       array ('KEYS_CONNECTED_EXPERIENCES') for better modularity and maintainability.
#     - Eliminated redundant conditional logic within 'disable_cloud_content'.
#     - Optimized variable scopes and string comparisons across all core functions.
#   v1.1.0 (2026-07-17):
#     - Added pre-flight system checks: OS verification (Darwin/macOS) and
#       dependency verification (command availability of 'defaults').
#     - Added privilege safety check: script will abort if run as root/sudo
#       to prevent applying preferences to the wrong user profile.
#     - Added suite-wide domain 'com.microsoft.office' to telemetry and
#       cloud configurations to ensure complete coverage.
#     - Enhanced telemetry settings: configured 'DiagnosticDataTypePreference'
#       to 'ZeroDiagnosticData'.
#     - Enhanced cloud features settings: configured modern connected experience
#       keys ('ConnectedOfficeExperiencesPreference', etc.) for suite and apps.
#     - Replaced 'set -euo pipefail' with 'set -Eeuo pipefail' and added an
#       EXIT trap handler for clean, predictable termination and error logging.
#     - Improved logging outputs with consistent, colored tags.
# ==============================================================================

set -Eeuo pipefail

# --- Color Definitions (Auto-detect TTY) ---
if [[ -t 1 ]]; then
    COLOR_BLUE='\033[1;34m'
    COLOR_GREEN='\033[1;32m'
    COLOR_YELLOW='\033[1;33m'
    COLOR_RED='\033[1;31m'
    COLOR_RESET='\033[0m'
else
    COLOR_BLUE=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_RED=''
    COLOR_RESET=''
fi

# --- Configurations ---
readonly PLISTS_TELEMETRY=(
    "com.microsoft.office"
    "com.microsoft.Word"
    "com.microsoft.Excel"
    "com.microsoft.Powerpoint"
    "com.microsoft.Outlook"
    "com.microsoft.onenote.mac"
    "com.microsoft.autoupdate2"
    "com.microsoft.Office365ServiceV2"
)

readonly PLISTS_CLOUD=(
    "com.microsoft.office"
    "com.microsoft.Word"
    "com.microsoft.Excel"
    "com.microsoft.Powerpoint"
)

readonly KEYS_CONNECTED_EXPERIENCES=(
    "ConnectedOfficeExperiencesPreference"
    "OfficeExperiencesAnalyzingContentPreference"
    "OfficeExperiencesDownloadingContentPreference"
    "OptionalConnectedExperiencesPreference"
)

# --- Logging Functions ---
log_info() {
    printf "%b[INFO]%b %s\n" "$COLOR_BLUE" "$COLOR_RESET" "$*"
}

log_success() {
    printf "%b[SUCCESS]%b %s\n" "$COLOR_GREEN" "$COLOR_RESET" "$*"
}

log_warn() {
    printf "%b[WARN]%b %s\n" "$COLOR_YELLOW" "$COLOR_RESET" "$*" >&2
}

log_error() {
    printf "%b[ERROR]%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$*" >&2
}

# --- Trap Handler ---
cleanup() {
    local exit_code=$?
    trap - EXIT INT TERM HUP
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script execution interrupted or failed."
    fi
}
trap cleanup EXIT INT TERM HUP

# --- Core Functions ---
disable_telemetry() {
    log_info "Disabling Microsoft Office Telemetry..."
    local plist
    local success=true

    for plist in "${PLISTS_TELEMETRY[@]}"; do
        # Disable general telemetry
        if defaults write "$plist" SendAllTelemetryEnabled -bool FALSE; then
            log_success "Disabled SendAllTelemetryEnabled for $plist"
        else
            log_error "Failed to disable SendAllTelemetryEnabled for $plist"
            success=false
        fi

        # Apply ZeroDiagnosticData for the suite-wide preference domain
        if [[ "$plist" == "com.microsoft.office" ]]; then
            if defaults write "$plist" DiagnosticDataTypePreference -string "ZeroDiagnosticData"; then
                log_success "Set DiagnosticDataTypePreference to ZeroDiagnosticData for $plist"
            else
                log_error "Failed to set DiagnosticDataTypePreference for $plist"
                success=false
            fi
        fi
    done

    if [[ "$success" == true ]]; then
        log_success "Telemetry optimization completed."
    else
        log_warn "Some telemetry preferences could not be set."
    fi
}

disable_cloud_content() {
    log_info "Disabling Microsoft Office Cloud Content features..."
    local plist
    local key
    local success=true

    for plist in "${PLISTS_CLOUD[@]}"; do
        # Disable legacy online content setting
        if defaults write "$plist" UseOnlineContent -integer 0; then
            log_success "Disabled UseOnlineContent for $plist"
        else
            log_error "Failed to disable UseOnlineContent for $plist"
            success=false
        fi

        # Disable modern connected experiences keys
        for key in "${KEYS_CONNECTED_EXPERIENCES[@]}"; do
            if defaults write "$plist" "$key" -bool FALSE; then
                log_success "Disabled $key for $plist"
            else
                log_error "Failed to disable $key for $plist"
                success=false
            fi
        done
    done

    if [[ "$success" == true ]]; then
        log_success "Cloud content optimization completed."
    else
        log_warn "Some cloud content preferences could not be set."
    fi
}

main() {
    echo "===================================================="
    echo "   Microsoft Office for macOS Optimizer Script      "
    echo "===================================================="

    # --- Pre-flight Checks ---
    # 1. OS Validation (Darwin only)
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_error "This script is designed for macOS only."
        exit 1
    fi

    # 2. Command Validation
    if ! command -v defaults >/dev/null 2>&1; then
        log_error "The 'defaults' command is not available."
        exit 1
    fi

    # 3. Privilege Validation (Avoid running as root/sudo)
    if [[ "$EUID" -eq 0 ]]; then
        log_error "This script should NOT be run as root (via sudo)."
        log_error "Please run it as the standard logged-in user so settings apply to your profile."
        exit 1
    fi

    # --- Execution ---
    disable_telemetry
    disable_cloud_content

    echo "===================================================="
    log_success "Optimization completed successfully."
}

main "$@"
