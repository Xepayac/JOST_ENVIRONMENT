#!/bin/bash
# This script starts the background services (Redis and Celery).

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Background Services ---"

# --- Activate Virtual Environment ---
echo "Activating Python virtual environment..."
source .venv/bin/activate
echo "Virtual environment activated."

# --- Start Redis Server ---
echo "Starting Redis server in the background..."
redis-server --daemonize yes
echo "Redis server started. Waiting for it to be ready..."
sleep 2 # Give Redis a moment to initialize

# --- Start Celery Worker ---
echo "Changing to frontend directory to start Celery worker..."
cd frontend
# Using nohup to ensure the worker runs in the background
nohup celery -A jost_platform.celery worker --loglevel=info > ../logs/celery.log 2>&1 &
echo "Celery worker started successfully in the background."
cd ..

echo "--- Background Services are running. ---"
