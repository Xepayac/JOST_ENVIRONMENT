#!/bin/bash

echo "Stopping Gunicorn, Celery, and Redis servers..."

# Gracefully stop Gunicorn (if it's running)
pkill -f gunicorn

# Gracefully stop Celery workers
pkill -f celery

# Find the Redis process and shut it down gracefully
redis-cli shutdown || echo "Redis not running or already shut down."

# Kill any remaining nohup processes from previous manual startups
ps -ef | grep 'nohup' | grep -v grep | awk '{print $2}' | xargs -r kill -9

echo "All services stopped."
