#!/bin/bash
# This script starts the Django development web server in the foreground.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Django Web Server ---"

# --- Activate Virtual Environment ---
echo "Activating Python virtual environment..."
source .venv/bin/activate
echo "Virtual environment activated."

# --- Start Django Development Server ---
echo "Changing to frontend directory to start the server..."
cd frontend
echo "Starting Django development server on 0.0.0.0:8080..."
# The server will run in the foreground and occupy this terminal.
python manage.py runserver 0.0.0.0:8080
