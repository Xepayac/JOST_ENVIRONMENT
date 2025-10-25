### Project Architecture: Blackjack Simulation Platform

This document outlines the technical architecture of the Blackjack Simulation Platform, a web application designed to run detailed simulations of the card game Blackjack. The system is composed of two primary components: a Python-based simulation engine and a Flask-based web interface. Communication between these two components is handled asynchronously using a Celery task queue with a Redis message broker.

---

### 1. The Backend: `jost_engine` (The Simulation Core)

The backend is a pure Python library responsible for the logic and execution of the Blackjack simulations. It is self-contained and has no web-related dependencies. Its purpose is to model the game accurately and run thousands of hands to generate statistical results. The engine is never called directly by the web server; it is always invoked by the background Celery worker process.

-   **Location:** `backend/src/jost_engine/`
-   **Python Path Coupling:** A critical architectural detail is how the backend is made available to the frontend. The `frontend/blackjack_simulator/celery_worker.py` script explicitly modifies the Python system path at runtime (`sys.path.insert(...)`) to include the `backend/src/` directory. This allows the Celery worker (part of the frontend project) to directly import and use the `jost_engine` as a Python package.
-   **Core Components:**
    -   `game.py`: The central orchestrator. It manages the simulation flow, including deck setup, running rounds, and coordinating between the player and the dealer.
    -   `player.py` & `dealer.py`: Model the participants in the game.
    -   `playing_strategy.py`: Defines the player's decision-making logic. It contains the `create_playing_strategy` function, which acts as a factory. 
        -   **Data Contract:** This function expects to receive a `strategy_config` dictionary (e.g., `{'name': 'h17_basic_strategy'}`) from the Celery worker to determine which strategy to load from the JSON data files.
    -   `betting_strategy.py`: Defines how the player wagers money. It is designed to be extensible.
    -   `simulation_logger.py`: Records all significant events and outcomes during a simulation, compiling the final data.
    -   **Data Directory (`/data`):** Contains all configurable data for the engine, stored in JSON format. This includes casino rules, default player profiles, betting strategies, and the detailed decision charts for playing strategies. This data-driven design makes the engine highly configurable without requiring code changes.

---

### 2. The Frontend: `blackjack_simulator` (The Web Interface)

The frontend is a Flask web application that provides a user interface for creating, configuring, running, and viewing simulations. It is responsible for initiating tasks and presenting the results, but it does not perform the heavy computational work itself. The application is configured through the `app.config` object in `app.py`, which sets up the database, Celery broker, and secret key.

-   **Location:** `frontend/blackjack_simulator/`
-   **Core Components:**
    -   `app.py`: The main Flask application. It defines all web routes, handles user requests, and manages database interactions.
        -   **Database Initialization:** On first run, it populates its own database by reading default JSON files for players, casinos, and strategies directly from the `backend/src/jost_engine/data` directory.
        -   **Task Dispatching:** Its most critical role is to package the user's simulation choices into a `simulation_config` dictionary and dispatch it to the Redis queue by calling `run_jost_simulation_task.delay()`.
        -   **Status Reporting:** It provides the `/task_status/<task_id>` endpoint that the frontend JavaScript polls to check for task completion.
    -   `celery_worker.py`: This script is the bridge between the web frontend and the simulation backend.
        -   **Task Definition:** It defines the `run_jost_simulation_task` function with the `@celery.task` decorator. This is the function that the background worker process executes.
        -   **Backend Invocation:** It receives the `simulation_config` from the Redis queue and uses it to import and call the `jost_engine` library, initiating the actual simulation run.
    -   **Database (`simulations.db`):** A SQLite database managed via Flask-SQLAlchemy, used to store user configurations, simulation settings, and final results.
    -   **Templates (`/templates`):** HTML files rendered with the **Jinja2** templating engine to create the user interface.
        -   `run_simulation.html`: The form where the user configures and starts a simulation.
        -   `simulation_status.html`: A dynamic status page containing JavaScript that polls the `/task_status/<task_id>` endpoint and redirects the user to the results page upon successful completion.

---

### 3. Asynchronous Communication Protocol: Celery & Redis

Directly running a computationally intensive simulation within a web request would time out and freeze the user interface. To solve this, the architecture uses a task queue to decouple the web server from the long-running simulation work. This creates a responsive user experience where the user can fire off a long-running task and be notified when it's done.

**The Technologies:**

*   **Celery:** A distributed task queue library for Python. It allows us to define tasks (run a simulation) that can be executed in the background by a separate worker process.
*   **Redis:** An in-memory data store used here for two distinct roles:
    1.  **Message Broker:** Acts as a central "mailbox" where the Flask app posts messages (tasks) and the Celery workers pick them up. This is configured by `CELERY_BROKER_URL='redis://localhost:6379/0'`.
    2.  **Result Backend:** Stores the state and final results of completed tasks, allowing the Flask app to retrieve them later. This is configured by `CELERY_RESULT_BACKEND='redis://localhost:6379/0'`.
*   **JSON (JavaScript Object Notation):** The standardized data format used to serialize the simulation configuration into a message that can be passed from the Flask app to the Celery worker.

**The Step-by-Step Communication Flow:**

1.  **Task Definition (The Worker's To-Do List):**
    *   **Location:** `frontend/blackjack_simulator/celery_worker.py`
    *   **Mechanism:** A Python function is decorated with `@celery.task`, which registers it as a background task that a Celery worker can execute.
    *   **Example:**
        ```python
        @celery.task
        def run_jost_simulation_task(simulation_config):
            # ... code to set up and run the jost_engine simulation ...
            # This code is executed by the background Celery worker.
            results = game.run_simulation(iterations)
            return json.loads(json.dumps(results, default=str))
        ```

2.  **Task Dispatch (Sending the Work Order):**
    *   **Location:** `frontend/blackjack_simulator/app.py` (within the `run_simulation_action` route)
    *   **Mechanism:** When a user submits the simulation form, the Flask application gathers all the settings into a single `simulation_config` dictionary. It then calls the `.delay()` method on the task function. This serializes the dictionary into a JSON message and places it on the Redis queue.
    *   **Example:**
        ```python
        @app.route('/simulation/<int:simulation_id>/run_action', methods=['POST'])
        def run_simulation_action(simulation_id):
            # ... gather all form data ...

            # The data is structured into a dictionary (JSON object)
            simulation_config = {
                "player": simulation.player.to_dict(),
                "casino": simulation.casino.to_dict(),
                "strategy": {"name": strategy_name}, # Correctly passing the name
                "betting_strategy": simulation.betting_strategy.to_dict(),
                "iterations": simulation.iterations
            }

            # Dispatch the task to the queue and get a task object back
            task = run_jost_simulation_task.delay(simulation_config)

            # Save the task ID and redirect the user
            simulation.task_id = task.id
            db.session.commit()
            return redirect(url_for('simulation_status', simulation_id=simulation.id))
        ```

3.  **Task Execution (Doing the Work):**
    *   **Process:** A separate `celery worker` process, which was started with the `start_app.sh` script, is constantly monitoring the Redis queue.
    *   **Mechanism:** It sees the new message, reads the task name (`run_jost_simulation_task`), and deserializes the JSON payload back into the `simulation_config` dictionary. It then calls the actual Python function with this dictionary as an argument, running the `jost_engine` simulation.

4.  **Result Retrieval (Checking for Completion):**
    *   **Location:** `frontend/blackjack_simulator/app.py` (the `task_status` route) and `frontend/blackjack_simulator/templates/simulation_status.html` (JavaScript code).
    *   **Mechanism:** The user is sent to a status page that contains JavaScript. This script repeatedly makes calls (polls) to the `/task_status/<task_id>` endpoint. The Flask backend uses the `task_id` to ask Celery (which checks the Redis result backend) for the task's current state (`PENDING`, `SUCCESS`, `FAILURE`).
    *   **Example (Backend - `app.py`):**
        ```python
        @app.route('/task_status/<task_id>')
        def task_status(task_id):
            task = celery.AsyncResult(task_id) # Check status using the ID
            if task.state == 'SUCCESS':
                outcomes = task.get() # Retrieve the return value from Redis
                # ... save results to database ...
                response = {'state': 'SUCCESS', 'result_url': result_url}
            # ... other statuses ...
            return jsonify(response)
        ```
    *   **Example (Frontend - JavaScript in template):**
        ```javascript
        function checkStatus(taskId) {
            fetch(`/task_status/${taskId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.state === 'SUCCESS') {
                        window.location.href = data.result_url; // Redirect to results
                    } else if (data.state !== 'FAILURE') {
                        setTimeout(() => checkStatus(taskId), 2000); // Check again
                    }
                });
        }
        ```
This decoupled, asynchronous architecture ensures the web application remains fast and responsive while still being able to manage and execute long, complex backend processes.