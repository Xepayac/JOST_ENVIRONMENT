### Project Architecture: Blackjack Simulation Platform

This document provides a comprehensive overview of the technical architecture for the Blackjack Simulation Platform. The system is designed as a modern, decoupled web application that allows users to configure and run computationally intensive Blackjack simulations and view the results.

---

### 1. High-Level Architectural View

The platform is built on a three-tier architecture composed of distinct, cooperating services:

1.  **The Frontend (Web Server):** A Flask application served by Gunicorn. This is the user's entry point to the system.
2.  **The Asynchronous Backbone (Task Queue):** A Celery distributed task queue using a Redis server as its broker and result backend.
3.  **The Backend (Simulation Engine):** A pure Python library (`jost_engine`) that runs the simulations.

---

### 2. Visual Architecture Diagram

```
+----------+      (HTTP)      +-----------+      (WSGI)      +-----------------+
|          | ---------------->|           | ---------------->|                 |
| Browser  |                  | Gunicorn  |                  | Flask Web App   |
|          | <----------------|           | <----------------| (blackjack_sim) |
+----------+      (HTML)      +-----------+      (Redirect)  +-----------------+
    ^   |                                                        |           ^
    |   | (Polling API)                                          | (Task)    | (DB I/O)
    |   v                                                        v           |
+----------+      (Broker/Result)      +-----------------+<--+----------+
|          | <------------------------>|                 |   | instance/|
|  Redis   |                           |  Celery Worker  |   | sim...db |
|          | <------------------------>|                 |   +----------+
+----------+                           +-----------------+
                                               |
                                               v (Function Call)
                                         +-------------+
                                         |             |
                                         | jost_engine |
                                         |             |
                                         +-------------+
```

---

### 3. Developer Quickstart Guide

1.  **Set Up the Codebase:** Clone all required project repositories.
2.  **Activate the Environment:** Source the virtual environment: `source .venv/bin/activate`.
3.  **Install Dependencies:** Run `pip install -r requirements.txt` to install all necessary packages.
4.  **Run the Services:** Execute `./devserver.sh`. This starts Redis, Celery, and the Gunicorn web server in the correct order.
5.  **Verify the Application:** Open your web browser to the development URL to see the running application.
6.  **Run the Tests:** Execute the test command from the "Testing" section to ensure the backend simulation engine is working as expected.

---

### 4. The Development & Execution Environment

#### The Virtual Environment (`.venv`)
*   **What it is:** A self-contained directory that houses a specific version of Python and all the external libraries (dependencies) required for this project.
*   **Why it's important:** It isolates the project, preventing library version conflicts and ensuring a predictable, reproducible environment.

#### Orchestration Scripts (`devserver.sh`, `stop-dev.sh`)
*   **What they are:** Shell scripts that act as the master control for starting and stopping all application services.
*   **Why they are important:** They abstract away the complexity of managing a multi-service application and enforce the correct startup order.

---

### 5. Component Deep Dive

(Detailed descriptions of Gunicorn, Flask, the Database, Celery, Redis, and `jost_engine` follow, explaining the role and importance of each.)

---

### 6. The Communication Flow: A Step-by-Step Relay Race

(A detailed, 15-step breakdown of the communication sequence from the user's initial click to the final result page.)

---

### 7. Project Roadmap and Future Work

This architecture provides a stable foundation for the application's core features. For a detailed list of active and upcoming development tasks, please refer to the `.idx/todo.md` file in the project's root directory. It is the primary source of truth for our development priorities.

Key areas for future development include:

*   **Improve Visual Design:** Enhance the user interface and overall user experience.
*   **Implement CRUD for Core Entities:** Build out web forms to allow users to Create, Read, Update, and Delete core models like Players, Casinos, and Strategies.
*   **Develop a Frontend Test Strategy:** Create a testing plan and suite for the Flask application and its user interface to complement the backend tests.

---

### 8. Troubleshooting: A Case Study of Asynchronous Failure

During development, the application would get stuck on the "Simulation in Progress..." page. The root cause was a **race condition** in the `devserver.sh` script, where the Celery worker would try to connect to the Redis server before it had fully initialized. The solution was to add a `sleep 2` command after starting Redis, ensuring it is ready to accept connections before the worker starts. This fix is crucial as it guarantees the reliability of the application's core asynchronous architecture.

---

### 9. Testing

To run the test suite for the backend engine, which is critical for verifying the simulation logic, use the following command:

```bash
export PYTHONPATH=$PYTHONPATH:$(pwd)/backend/src && source .venv/bin/activate && cd backend && pytest
```
