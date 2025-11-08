# Web Service Deep Dive: Anatomy of the Computational Cloud

## 1. The Mission: A Scalable, Stateless Job Orchestrator

This document provides a detailed breakdown of the JOST Web Service.

**Its Core Purpose:** To act as a **stateless, horizontally scalable, API-driven job orchestrator**. It accepts fully-formed simulation jobs from a client (like the `user_terminal`), uses a scalable pool of background workers to execute them via the `jost_engine`, and holds the results for retrieval.

---

## 2. The Technology Stack

Our service is built on a foundation of robust, industry-standard tools:

*   **Python** & **Django**: The core language and web framework.
*   **Django REST Framework (DRF)**: The toolkit for building our web API.
*   **Celery**: The asynchronous task queue that manages our scalable pool of workers.
*   **Redis**: The message broker that acts as the "job board" for Celery.
*   **Django Development Server**: Used in our IDX environment for its compatibility with the platform's preview system.

---

## 3. Project Structure: A "Flat" and Robust Layout

The web service, located in the `/service` directory, now follows a **standard, "flat" Django project layout**. This was a deliberate refactoring to eliminate complexity and improve robustness.

*   `/service/`: This is the **single application root**. It contains:
    *   `manage.py`: The Django command-line utility.
    *   `settings.py`, `urls.py`, `wsgi.py`: The core project configuration files.
    *   `celery_app.py`: The configuration for our Celery application.
*   `/service/api/`: The Django app that handles our machine-to-machine API. This includes the `/api/submit/` and `/api/defaults/` endpoints.
*   `/service/simulator/`: The Django app responsible for managing the `SimulationJob` data model and the Developer Workbench web interface.

This flat structure permanently solves the "Two-Root Problem" and eliminates the need for pathing hacks like `PYTHONPATH` or `--chdir` in our core application logic.

---

## 4. The Request Lifecycle: Submitting a Simulation

1.  **API Request:** A client (like the `user_terminal` or our Developer Workbench) sends a `POST` request to `/api/submit/`. The body of this request is a **fully-hydrated JSON object** containing the complete simulation configuration.
2.  **API View:** The `submit_simulation` view in `api/views.py` receives the request.
3.  **Database Interaction:** It creates a new `SimulationJob` object in the database with a status of `PENDING` and stores the incoming JSON config in the `request_data` field.
4.  **Dispatch to Queue:** The view calls `.delay()` on our Celery task (`run_jost_simulation_task.delay(new_job.id)`). This places a message containing the new job's ID onto the Redis queue.
5.  **API Response:** The web server immediately returns a `202 Accepted` response to the client, including the `job_id`. The web request is now finished.

---

## 5. The Asynchronous Workforce: The Power of Celery

1.  **Job Pickup:** A Celery worker process, which is constantly monitoring the Redis queue, picks up the message with the `job_id`.
2.  **Task Execution:** The worker executes the `run_jost_simulation_task`.
3.  **Database Fetch:** The task retrieves the full `SimulationJob` object from the database using the provided `job_id`.
4.  **Engine Execution:** The task passes the `request_data` (the complete JSON config) to the `jost_engine`'s `run_simulation_from_config` function and waits for it to complete.
5.  **Save Results:** Once the engine returns the results, the task updates the `SimulationJob` object, setting its status to `COMPLETE` and saving the results JSON to the `result_data` field.

This decoupling is the key to our scalability. We can run hundreds of worker processes simultaneously, and each one can independently pull jobs from the queue.

---

## 6. The Local Workshop: The IDX-Native Environment

Our development environment is now **fully declarative and automated**, managed by the `.idx/dev.nix` file.

As detailed in `DEVELOPMENT_ENVIRONMENT.md`, this file uses **native IDX features** to define and launch our entire application stack.
*   `idx.services` automatically starts our background processes (`redis` and our `celery` worker).
*   `idx.previews` automatically starts our Django development server and connects the IDE's preview panel.

This "one-click" setup is the final, robust implementation of our "Foundation First" mandate, ensuring a stable and frictionless development experience.
