# JOST Blackjack Simulation Platform

This repository contains the main development environment for a professional-grade Blackjack simulation platform. The system allows users to configure, run, and analyze the results of complex, high-volume Blackjack simulations.

The platform's frontend is built with the **Django** web framework, and it uses **Celery** and **Redis** to manage computationally intensive simulation tasks asynchronously. The core simulation logic is provided by the `jost_engine`, a standalone Python library.

---

## 1. Key Architectural Documents

Before diving into the code, it is highly recommended to review the primary architectural and planning documents. These files provide the necessary context for understanding the project's goals, structure, and our collaborative workflow.

*   **`prompt.md`**: Outlines our "Architect and Builder" collaboration model and contains the high-level roadmap for the current development sprint. **This is the best place to start.**
*   **`Ecosystem_Architecture_Plan.md`**: This is the primary architectural blueprint for the entire product suite, including the long-term vision and feature backlog.
*   **`.idx/ARCHITECTURE.md`**: Provides a detailed, deep-dive of the system's *current* technical architecture.

## 2. Getting Started (Django Environment)

This project is configured to run in a Nix-based environment managed by Firebase Studio.

### Quick Start: Running the Application

A streamlined script handles the entire application stack (web server, background worker, and message broker).

1.  **Start All Services:**
    To start the Django web server, the Celery worker, and the Redis server, run the `start-dev.sh` script from the project root:
    ```bash
    ./start-dev.sh
    ```
    This will start all necessary services and the Django development server will occupy the current terminal.

2.  **Stop All Services:**
    To gracefully shut down all components, open a **new terminal** and run the `stop-dev.sh` script:
    ```bash
    ./stop-dev.sh
    ```

### Initial Setup (First Time Only)

Before running the application for the first time after the Django migration, you need to set up the database.

1.  **Navigate to the Frontend Directory:**
    ```bash
    cd frontend
    ```

2.  **Apply Database Migrations:** This command creates the database schema based on the Django models.
    ```bash
    python manage.py migrate
    ```

3.  **Create a Superuser:** To access the powerful Django Admin interface, you must create an administrator account.
    ```bash
    python manage.py createsuperuser
    ```
    Follow the prompts to create your user. You can then access the admin panel at `/admin` on the development server.

### Default Superuser Credentials

For convenience, a default superuser has been created with the following credentials:

*   **Username:** `admin`
*   **Password:** `complexpassword123`

---
*For details on the multi-repository Git structure, please see `.idx/Git.md`*.
