#!/bin/bash

echo "--- Forcefully Shutting Down All Development Services ---"

# This command finds any process that has 'celery' or 'manage.py runserver' in its command line
# and is running from the current project's virtual environment (.venv), then terminates it.
# This is a robust way to ensure all old and new development processes are stopped.
pkill -f ".venv/bin/python.*(celery|manage.py runserver)" || true
pkill -f "redis-server" || true

echo "All services have been stopped."
