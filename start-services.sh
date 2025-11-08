#!/usr/bin/env bash

# ==============================================================================
# Development Service Orchestrator (for background tasks)
#
# This script is now a lightweight wrapper around 'foreman'.
# Its primary purpose is to start the background services (`redis`, `worker`)
# defined in `Procfile.dev`. The `web` service is handled by the IDX Preview.
# ==============================================================================

set -e

COLOR_GREEN="\033[0;32m"; COLOR_BLUE="\033[0;34m"; COLOR_YELLOW="\033[0;33m"; COLOR_RED="\033[0;31m"; COLOR_RESET="\033[0m"

log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"; }

main() {
    case "$1" in
        start)
            log_info "Starting background services (redis, worker) with foreman..."
            # Using exec to replace this script's process with foreman's
            exec foreman start -f Procfile.dev
            ;;
        migrate)
            log_info "Activating venv and running migrations..."
            source .venv/bin/activate
            (cd service && python manage.py migrate)
            ;;
        *)
            echo "Usage: $0 {start|migrate}"
            echo "  start   - Starts the background redis and celery services."
            echo "  migrate - Runs Django database migrations."
            exit 1
            ;;
    esac
}

main "$@"
