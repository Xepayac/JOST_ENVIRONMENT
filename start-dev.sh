#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Create Log Directory ---
echo "Creating logs directory..."
mkdir -p logs
echo "Logs directory created."

# --- Activate Virtual Environment ---
echo "Activating Python virtual environment..."
source .venv/bin/activate
echo "Virtual environment activated."

# --- Start Redis Server ---
echo "Starting Redis server in the background..."
redis-server --daemonize yes
echo "Redis server started."

# --- Start Celery Worker ---
echo "Changing to frontend/blackjack_simulator directory..."
cd frontend/blackjack_simulator
echo "Starting Celery worker in the background..."
nohup celery -A celery_worker.celery worker --loglevel=info > ../../logs/celery.log 2>&1 &
echo "Celery worker started."
cd ../..
echo "Returned to root directory."

# --- Start Gunicorn Web Server ---
echo "Changing to frontend directory..."
cd frontend
echo "Starting Gunicorn web server in the background..."
nohup gunicorn --workers 1 --threads 1 --bind 0.0.0.0:8080 --access-logfile ../logs/gunicorn-access.log --error-logfile ../logs/gunicorn-error.log wsgi:app > ../logs/gunicorn.log 2>&1 &
echo "Gunicorn web server started."
cd ..
echo "Returned to root directory."
echo "All services started."
