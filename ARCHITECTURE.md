# Deep Dive: The JOST Ecosystem Component Architecture

---

## Component 1: The `jost_engine` (The Specialist Subcontractor)
*(This section remains unchanged)*

---

## Component 2: The Web Service (The "Computational Cloud")

### 2.A. Overview & Core Principle

The Web Service is the central, scalable hub for coordinating large-scale simulation jobs. It is the "General Contractor" that manages work for the `jost_engine`.

**Core Principle: API First.** The primary interface and product of this component is its machine-to-machine API, which serves the `user_terminal`. All other interfaces (like a web dashboard) are secondary and exist only to support the development and testing of the API and its underlying services.

### 2.B. Key Responsibilities
*   **Provide a Job API:** Expose secure, programmatic endpoints for the `user_terminal` to submit jobs, check status, and retrieve results.
*   **Manage a Job Queue:** Use a database (`SimulationJob` model) as a central ledger for all in-flight jobs.
*   **Orchestrate Background Workers:** Use Redis and Celery to manage a scalable pool of workers.
*   **Adhere to the PaaS Contract:** Run a production WSGI server (Gunicorn) that correctly binds to the host and port (`0.0.0.0:$PORT`).

### 2.C. Core Components Breakdown

#### The API Layer (Django REST Framework)
*   **Purpose:** To provide the HTTP endpoints that the `user_terminal` interacts with. This is the **primary product** of the Web Service.
*   **Technology:** Built using Django REST Framework (DRF) for robustness and adherence to industry standards.
*   **Key Components:** Serializers (to validate and convert data), API Views (to handle requests), and Token Authentication (for security).

#### The Developer Dashboard (Django Views & Templates)
*   **Purpose:** To provide a simple, powerful **internal tool** for developers to test and diagnose the service pipeline. This is **not** a user-facing product.
*   **Functionality:** Includes a "Raw JSON Runner" for submitting custom test cases and a "Job History" view for monitoring recent activity.

#### The Production Web Server (Gunicorn & Procfile)
*   **Purpose:** To serve the Django application in a production-ready manner.
*   **Gunicorn:** A WSGI server that manages multiple worker processes.
*   **Procfile:** A one-line file (`web: gunicorn service.wsgi`) that tells the cloud platform how to start the service.

#### The Central Ledger (`simulator/models.py`)
*   **Purpose:** To define the schema for the service's transactional database.
*   **`SimulationJob` Model:** The single source of truth for a job's status and data.

#### The Asynchronous Workforce (Celery)
*   **Purpose:** To execute simulations in the background without blocking the web server.
*   **Redis:** Acts as the message broker or "job board".
*   **The Celery Worker:** A separate, scalable process.
*   **`simulator/tasks.py`:** Contains the code the worker executes.
*   **Key Configuration:** The `settings.py` file must define the `CELERY_BROKER_URL`.

#### Local Development Environment
*   **Purpose:** To provide a consistent local environment for testing the Web Service.
*   **Nix Configuration (`.idx/dev.nix`):** Defines all system-level dependencies.
*   **Startup Scripts:** `start-dev.sh` (to start all services) and `stop-dev.sh` (to clean up).

---

## Component 3: The `user_terminal` (The User's Home Base)
*(This section remains unchanged)*
