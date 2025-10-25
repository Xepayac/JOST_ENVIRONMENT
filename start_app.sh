#!/bin/bash

# Exit script on any error
set -e

# Activate Python virtual environment
echo ">>> Activating virtual environment..."
source .venv/bin/activate

# --- Start Redis Server ---
# Check if Redis is running by pinging it.
if ! redis-cli ping > /dev/null 2>&1; then
    echo ">>> Redis is not running. Starting Redis server in the background..."
    redis-server --daemonize yes
    sleep 1 # Wait for Redis to initialize
    echo ">>> Redis server started."
else
    echo ">>> Redis is already running."
fi

# --- Start Celery Worker ---
echo ">>> Starting Celery worker in the background..."
pkill -f "celery -A frontend.blackjack_simulator.celery_worker" || true
# Add current directory to PYTHONPATH so worker can find the 'frontend' module
export PYTHONPATH=$PYTHONPATH:.
celery -A frontend.blackjack_simulator.celery_worker worker --loglevel=info --logfile=celery.log --detach
echo ">>> Celery worker started. Logs are in celery.log."


# --- Start Flask Web Server ---
echo ">>> Starting Flask web server..."
./devserver.sh
