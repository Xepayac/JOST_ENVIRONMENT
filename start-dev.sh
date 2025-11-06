#!/bin/bash
# This is the single, unified script for starting all development services.

set -e

echo "--- Stopping any old services to ensure a clean start ---"
# Use fuser to kill whatever is on the port, and pkill for redis/celery.
fuser -k ${PORT:-8080}/tcp || true
pkill -f "redis-server" || true
pkill -f "celery" || true
echo "Old services stopped."
sleep 1

echo "--- Starting All Development Services ---"

# --- Activate Virtual Environment ---
echo "Activating Python virtual environment..."
source .venv/bin/activate
echo "Virtual environment activated."

# --- Set Data Directory Environment Variable ---
export JOST_DATA_DIR=$(pwd)/data
echo "JOST_DATA_DIR set to: $JOST_DATA_DIR"

# --- Start Redis Server (Background) ---
echo "Starting Redis server in the background..."
redis-server --daemonize yes
echo "Redis server started. Waiting 2 seconds for it to initialize..."
sleep 2

# --- Start Celery Worker (Background) ---
echo "Starting Celery worker in the background..."
(cd service && nohup celery -A service worker --loglevel=info > ../logs/celery.log 2>&1 &)
echo "Celery worker started. Logs are available in logs/celery.log"

# --- Start Gunicorn Web Server (Foreground) ---
echo "Starting Gunicorn web server..."
# Gunicorn will automatically use the $PORT variable if it's set by the environment,
# otherwise it will fall back to 8080.
(cd service && gunicorn --bind 0.0.0.0:${PORT:-8080} service.wsgi)
