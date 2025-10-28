# Blackjack Simulator

This is a Flask-based web application for running Blackjack simulations. It uses Celery and Redis to handle long-running simulation tasks in the background, ensuring the user interface remains responsive.

## Quick Start: Running the Application

Thanks to a streamlined script-based setup, running the entire application stack (web server, background worker, and message broker) requires just one command.

### 1. Start All Services

To start the Flask web server, the Celery worker, and the Redis server, simply run the `start-dev.sh` script from the project root:

```bash
./start-dev.sh
```

This single command will:
- Activate the Python virtual environment.
- Start the Redis server in the background.
- Start the Celery background worker.
- Start the Gunicorn web server, which will occupy the current terminal.

Your application will be running and accessible.

### 2. Stop All Services

To gracefully shut down all running components (Gunicorn, Celery, and Redis), open a **new terminal** and run the `stop-dev.sh` script:

```bash
./stop-dev.sh
```

This ensures a clean shutdown of all background processes.

## Initial Setup (First Time Only)

Before you run the application for the very first time, you need to create the database tables. This only needs to be done once.

1.  **Activate Virtual Environment**: The command needs to run within the project's Python virtual environment.
    ```bash
    source .venv/bin/activate
    ```

2.  **Initialize Database**: Navigate to the `frontend` directory and use the `flask init-db` command.
    ```bash
    cd frontend
    flask init-db
    cd ..
    ```

After completing this one-time setup, you can use the `./start-dev.sh` and `./stop-dev.sh` scripts for all future development sessions.
