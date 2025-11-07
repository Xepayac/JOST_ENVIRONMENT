#!/usr/bin/env bash

# ==============================================================================
# Robust Development Service Orchestrator
#
# This script manages the complete lifecycle (start, stop, status, logs)
# for a Django, Celery, and Redis stack in a non-containerized environment.
#
# It is:
# 1. Stateful: Uses PID files in .run/ to track process state.
# 2. Context-Aware: Uses PROJECT_ROOT and PYTHONPATH to solve all ModuleNotFoundErrors.
# 3. Robust: Uses graceful SIGTERM-then-SIGKILL shutdowns.
# 4. Observable: Uses native app logging to a central logs/ directory.
# ==============================================================================

set -e

COLOR_GREEN="\033[0;32m"; COLOR_BLUE="\033[0;34m"; COLOR_YELLOW="\033[0;33m"; COLOR_RED="\033[0;31m"; COLOR_RESET="\033[0m"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$SCRIPT_DIR
DJANGO_ROOT="$PROJECT_ROOT/service" # The directory where manage.py lives
PROJECT_NAME="service" # The name of the inner Django project folder

VENV_PATH="$PROJECT_ROOT/.venv"
RUN_DIR="$PROJECT_ROOT/.run"
LOG_DIR="$PROJECT_ROOT/logs"

PID_REDIS="$RUN_DIR/redis.pid"; PID_GUNICORN="$RUN_DIR/gunicorn.pid"; PID_CELERY="$RUN_DIR/celery.pid"
LOG_REDIS="$LOG_DIR/redis.log"; LOG_GUNICORN_ACCESS="$LOG_DIR/gunicorn-access.log"; LOG_GUNICORN_ERROR="$LOG_DIR/gunicorn-error.log"; LOG_CELERY="$LOG_DIR/celery.log"

log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"; }
log_success() { echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"; }
log_error() { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1" >&2; }

activate_venv() {
    if [ -f "$VENV_PATH/bin/activate" ]; then
        log_info "Activating Python virtual environment..."
        source "$VENV_PATH/bin/activate"
    else
        log_error "Virtual environment not found at $VENV_PATH"; exit 1;
    fi
}

setup_dirs() { mkdir -p "$RUN_DIR" "$LOG_DIR"; }

run_migrations() {
    log_info "Running Django database migrations..."
    python "$DJANGO_ROOT/manage.py" migrate
}

stop_process() {
    local pid_file=$1; local name=$2
    if [ ! -f "$pid_file" ]; then log_info "$name is already stopped."; return 0; fi
    local pid; pid=$(cat "$pid_file")
    if [ -z "$pid" ]; then log_warn "$name PID file is empty. Removing."; rm -f "$pid_file"; return 0; fi
    if ! kill -0 "$pid" 2>/dev/null; then log_warn "$name (PID $pid) not found. Removing stale PID file."; rm -f "$pid_file"; return 0; fi
    log_info "Stopping $name (PID $pid) with SIGTERM..."; kill -TERM "$pid" 2>/dev/null
    for _ in {1..10}; do if ! kill -0 "$pid" 2>/dev/null; then log_success "$name stopped gracefully."; rm -f "$pid_file"; return 0; fi; sleep 1; done
    log_warn "$name (PID $pid) did not stop. Escalating to SIGKILL."; kill -KILL "$pid" 2>/dev/null; sleep 1
    if ! kill -0 "$pid" 2>/dev/null; then log_success "$name stopped forcefully."; else log_error "Failed to stop $name (PID $pid)."; fi
    rm -f "$pid_file"
}

check_status() {
    setup_dirs
    _check_process_status "$PID_REDIS" "Redis"
    _check_process_status "$PID_GUNICORN" "Gunicorn"
    _check_process_status "$PID_CELERY" "Celery"
}

_check_process_status() {
    local pid_file=$1; local name=$2
    if [ ! -f "$pid_file" ]; then echo -e "$name: ${COLOR_RED}STOPPED${COLOR_RESET}"; return; fi
    local pid; pid=$(cat "$pid_file")
    if [ -z "$pid" ]; then echo -e "$name: ${COLOR_RED}STOPPED${COLOR_RESET} (Empty PID)"; return; fi
    if kill -0 "$pid" 2>/dev/null; then echo -e "$name: ${COLOR_GREEN}RUNNING${COLOR_RESET} (PID $pid)"; else echo -e "$name: ${COLOR_RED}STOPPED${COLOR_RESET} (Stale PID $pid)"; fi
}

wait_for_pid() {
    local pid_file=$1; local name=$2
    log_info "Waiting for $name to start..."; for _ in {1..10}; do if [ -f "$pid_file" ]; then local pid; pid=$(cat "$pid_file"); if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then log_success "$name started (PID $pid)."; return 0; fi; fi; sleep 1; done
    log_error "Timeout waiting for $name to start."; log_error "Check log: tail -f $LOG_DIR/${name,,}.log"; return 1
}

start_redis() {
    log_info "Starting Redis server..."; redis-server --daemonize yes --port 6379 --pidfile "$PID_REDIS" --logfile "$LOG_REDIS" --loglevel notice; wait_for_pid "$PID_REDIS" "Redis"
}

start_gunicorn() {
    log_info "Starting Gunicorn server..."; 
    gunicorn "$PROJECT_NAME.wsgi:application" --bind 0.0.0.0:8080 --workers 3 --daemon --pid "$PID_GUNICORN" --access-logfile "$LOG_GUNICORN_ACCESS" --error-logfile "$LOG_GUNICORN_ERROR"; 
    wait_for_pid "$PID_GUNICORN" "Gunicorn"
}

start_celery() {
    log_info "Starting Celery worker..."; 
    celery -A "$PROJECT_NAME.celery" worker --detach --pidfile "$PID_CELERY" --logfile "$LOG_CELERY" --loglevel=INFO; 
    wait_for_pid "$PID_CELERY" "Celery"
}

start_services() {
    log_info "Starting all services..."; setup_dirs
    log_info "Ensuring clean state by stopping old services..."; stop_services || true
    activate_venv
    
    # ** THE CRITICAL FIX **
    # Explicitly add the Django project directory to the PYTHONPATH.
    export PYTHONPATH="$DJANGO_ROOT:$PYTHONPATH"
    
    log_info "--- Installing/Verifying Dependencies ---"; pip install -r requirements.txt; pip install -e backend
    run_migrations
    start_redis
    start_gunicorn
    start_celery
    log_success "All services are up and running."; echo ""; check_status
}

stop_services() {
    log_info "Stopping all services..."; stop_process "$PID_CELERY" "Celery"; stop_process "$PID_GUNICORN" "Gunicorn"; stop_process "$PID_REDIS" "Redis"
    log_info "Final cleanup..."; pkill -f "gunicorn.*$PROJECT_NAME" || true; pkill -f "celery.*$PROJECT_NAME" || true
    log_success "All services are stopped."
}

stream_logs() {
    log_info "Streaming all logs... (Press Ctrl+C to stop)"; setup_dirs; touch "$LOG_REDIS" "$LOG_GUNICORN_ACCESS" "$LOG_GUNICORN_ERROR" "$LOG_CELERY"; tail -f "$LOG_DIR"/*.log
}

main() {
    case "$1" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            stop_services
            start_services
            ;;
        status)
            check_status
            ;;
        logs)
            stream_logs
            ;;
        migrate)
            activate_venv
            run_migrations
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|logs|migrate}"
            exit 1
            ;;
    esac
}

main "$@"
