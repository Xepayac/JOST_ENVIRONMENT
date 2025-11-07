# Web Service Deep Dive: Anatomy of the Computational Cloud

## 1. The Mission: A Scalable Powerhouse for Simulation

This document provides a detailed breakdown of the JOST Web Service, the "computational cloud" of our ecosystem.

**Its Core Purpose:** To act as a scalable, API-driven powerhouse. It receives simulation jobs from the `user_terminal`, runs them using the `jost_engine` at a massive scale, and provides the results back to the user. It is the bridge between a player's local machine and a supercomputer.

---

## 2. The Technology Stack

Our service is built on a foundation of robust, industry-standard tools:

*   **Python:** The core programming language.
*   **Django:** The high-level web framework that provides the application's structure, database management, and administrative tools.
*   **Django REST Framework (DRF):** A powerful toolkit that sits on top of Django, specifically for building clean, efficient, and secure web APIs.
*   **PostgreSQL:** The production-grade database used to store all job and profile information. (Note: We use SQLite in local development for simplicity).
*   **Celery:** The asynchronous task queue. This is the "heavy lifter" that allows us to run time-consuming simulations in the background without locking up the web server.
*   **Redis:** The message broker. It acts as the "to-do list" or "job board" where the web server places tasks for Celery workers to pick up.
*   **Gunicorn:** The production WSGI server. It is the robust, multi-process engine that serves our Django application to the outside world.

---

## 3. Project Structure: A Tour of the `service` Directory

The web service is a standard Django project with several dedicated "apps," each with a specific responsibility.

*   `service/service/`: This is the main project configuration directory.
    *   `settings.py`: The master configuration file. It defines everything from installed apps and database connections to the location of our Celery broker.
    *   `urls.py`: The master URL router. This is the main "switchboard" that directs incoming requests to the correct Django app.
*   `service/simulator/`: This app's sole responsibility is to manage the lifecycle of a simulation.
    *   `models.py`: Defines the `SimulationJob` model, which is the single source of truth for every job in our system. It stores the user's request, the job's current status (`PENDING`, `RUNNING`, `COMPLETE`), and the final result data.
    *   `tasks.py`: Contains `run_jost_simulation_task`, the Celery task that is the critical link between the web service and the `jost_engine`.
*   `service/api/`: This app handles the core, machine-to-machine API for submitting jobs and retrieving results.
    *   `urls.py`: Defines the specific endpoints like `/api/submit/` and `/api/status/<job_id>/`.
    *   `views.py`: Contains the logic to handle requests to these endpoints, such as creating a new `SimulationJob` in the database and dispatching it to the Celery queue.
*   `service/profiles/`: This is the app responsible for the new Custom Profile Management API.
    *   `models.py`: Defines the `Profile` model, which stores a user's saved casino rules, player strategies, etc. It has a `ForeignKey` relationship to the main Django `User` model, ensuring data is securely associated with its owner.
    *   `serializers.py`, `views.py`, `urls.py`: These files work together to create the secure, user-specific CRUD (Create, Read, Update, Delete) endpoints for managing profiles.

---

## 4. The Request Lifecycle: From User Terminal to Final Result

Understanding the flow of a request is key to understanding the service.

1.  **API Request:** The `user_terminal` sends an HTTP request (e.g., a `POST` request to `/api/profiles/` with JSON data) to the web service.
2.  **Gunicorn Receives:** Gunicorn, our web server, receives the request.
3.  **URL Routing:** Django's URL router in `service/urls.py` examines the path and directs the request to the appropriate view in the `profiles` app.
4.  **Authentication:** The `ProfileViewSet` in `views.py` first checks if the user is authenticated. If not, it rejects the request with a `401 Unauthorized` error.
5.  **Serialization & Validation:** The view uses the `ProfileSerializer` to validate the incoming JSON. Does it have the required fields? Are the data types correct? If not, it returns a `400 Bad Request` error.
6.  **Database Interaction:** If the data is valid, the view's `perform_create` method saves a new `Profile` object to the database, automatically linking it to the authenticated user.
7.  **API Response:** The view sends a `201 Created` response back to the `user_terminal`, including the JSON representation of the newly created profile.

---

## 5. The Asynchronous Workforce: The Power of Celery

The process for running a simulation is special because it takes too long for a normal web request.

1.  A user submits a job to `/api/submit/`. The view creates a `SimulationJob` object in the database with a status of `PENDING`.
2.  Instead of running the simulation itself, the view calls `.delay()` on our Celery task: `run_jost_simulation_task.delay(job.id)`.
3.  This places a message in the Redis queue. The web request is now finished and returns a `202 Accepted` response to the user almost instantly.
4.  **Separately**, a Celery worker process, which is always listening to the Redis queue, picks up the message.
5.  The worker runs the task. It retrieves the `SimulationJob` from the database, calls the `jost_engine`'s `run_simulation_from_config` function with the job's data, and waits for it to complete.
6.  Once the `jost_engine` returns the results, the worker updates the `SimulationJob` object in the database, setting the status to `COMPLETE` and saving the result data.

This decoupling is the key to the service's scalability and responsiveness.

---

## 6. The Local Workshop: The `start-services.sh` Orchestrator

To manage this complex, multi-process system in development, we use the `start-services.sh` script. As detailed in `DEVELOPMENT_ENVIRONMENT.md`, this script is the single entry point for managing the entire stack. It reliably starts, stops, and monitors Gunicorn, Celery, and Redis, solving common development friction and ensuring our local environment perfectly mirrors the architecture of a production deployment.
