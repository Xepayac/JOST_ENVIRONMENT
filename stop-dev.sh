#!/bin/bash
# This script forcefully stops the background Redis and Celery processes.

echo "--- Forcefully Shutting Down Background Services ---"
pkill -f "redis-server" || true
pkill -f "celery" || true
echo "Background services have been stopped."
