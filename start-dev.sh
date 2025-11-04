#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Cleanup function ---
cleanup() {
    echo "Shutting down servers..."
    pkill -f "redis-server" || true
    pkill -f "celery" || true
    pkill -f "gunicorn" || true
    echo "Servers shut down."
}

# --- Trap EXIT signal to run cleanup function ---
trap cleanup EXIT

# --- Kill any lingering old processes ---
echo "Killing any old server processes..."
pkill -f "redis-server" || true
pkill -f "celery" || true
pkill -f "gunicorn" || true
echo "Old processes killed."

# --- Create Log Directory ---
echo "Creating logs directory..."
mkdir -p logs
echo "Logs directory created."

# --- Activate Virtual Environment ---
echo "Activating Python virtual environment..."
source .venv/bin/activate
echo "Virtual environment activated."

# --- Install Dependencies ---
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt
echo "Dependencies installed."

# --- Install Backend Package ---
echo "Installing backend package in editable mode..."
pip install -e backend
echo "Backend package installed."

# --- Start Redis Server ---
echo "Starting Redis server in the background..."
redis-server --daemonize yes
echo "Redis server started. Waiting for it to be ready..."

# --- Wait for Redis to be ready ---
retries=5
while ! redis-cli ping > /dev/null 2>&1; do
    retries=$((retries - 1))
    if [ $retries -eq 0 ]; then
        echo "Redis is not responding. Exiting."
        exit 1
    fi
    echo "Waiting for Redis... ($retries retries left)"
    sleep 1
done
echo "Redis is ready."

# --- Start Celery Worker ---
echo "Changing to frontend directory to start Celery worker..."
cd frontend
nohup celery -A jost_platform.celery worker --loglevel=info > ../logs/celery.log 2>&1 &
echo "Celery worker started. Giving it a moment to initialize..."
sleep 3 # Give Celery worker a few seconds to start up.

# --- Start Gunicorn Web Server ---
echo "Starting Gunicorn in the frontend directory..."
# The Gunicorn server will run in the foreground and occupy this terminal.
gunicorn --bind 0.0.0.0:8080 jost_platform.wsgi:application
