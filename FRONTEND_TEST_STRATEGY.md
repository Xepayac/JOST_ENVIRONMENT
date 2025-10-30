# Frontend Test Strategy for the Blackjack Simulator

This document outlines the comprehensive testing strategy for the Flask frontend of the Blackjack Simulator application. Its purpose is to ensure the application is reliable, stable, and easy to maintain as new features are added.

---

### 1. Executive Summary & Chosen Tools

To ensure consistency with the backend and to leverage powerful, industry-standard tools, we will use the **Pytest** framework along with the **`pytest-flask`** extension.

Our strategy is built on two core principles:

1.  **Test Isolation:** Tests must not depend on or interact with the development database or other live services. We will achieve this by using a temporary, in-memory SQLite database for each test run.
2.  **Mocking External Services:** We will not use live Redis or Celery worker processes during automated testing. Instead, we will configure Celery to run in a special synchronous "eager" mode, which executes tasks immediately in the same thread. This allows us to test the entire simulation workflow quickly and reliably without the complexity of managing background processes.

---

### 2. Core Testing Concepts Explained

#### Test Database
-   **What:** A new `TestingConfig` class in `config.py` will instruct Flask to use an in-memory SQLite database (`sqlite:///:memory:`).
-   **Why:** This is crucial for test reliability. Every test run will start with a brand new, empty database. This prevents data from one test from interfering with another and ensures that tests always run in a predictable environment.

#### Mocking Celery & Redis
-   **What:** The `TestingConfig` will set `CELERY_TASK_ALWAYS_EAGER = True`.
-   **Why:** This is the most important part of our strategy. When this setting is active, calling `celery.send_task()` does **not** send a message to Redis. Instead, the task is executed immediately, just like a regular Python function. This allows us to test the entire simulation workflow—from clicking the "Run" button to seeing the results—in a single, synchronous test function. It completely removes the need for a running Redis server or Celery worker, making our tests faster and far less brittle.

#### Test Structure
-   **Directory:** All frontend tests will be located in a new `frontend/tests/` directory.
-   **Fixtures (`frontend/tests/conftest.py`):** This special file will contain all the setup code needed to run our tests. It will define "fixtures" that create the Flask application instance, a test client for making web requests, and a database session for our tests.
-   **Test Files (`test_*.py`):** Individual tests will be organized into files with names like `test_routes.py` and `test_management.py`.

---

### 3. Step-by-Step Implementation Plan

This is the concrete plan we will follow to build our test suite.

#### Step 1: Initial Setup and Configuration
1.  **Add Dependencies:** Add `pytest` and `pytest-flask` to the `requirements.txt` file.
2.  **Create Test Config:** Add the `TestingConfig` class to `frontend/blackjack_simulator/config.py` (as we have already planned).
3.  **Create Test Directory:** Create the `frontend/tests/` directory.

#### Step 2: Create Core Fixtures (`frontend/tests/conftest.py`)
This is the foundation of our test suite.
1.  **`app` Fixture:** Creates an instance of our Flask application using the `TestingConfig`.
2.  **`client` Fixture:** This is the most important fixture. It provides a test "client" that acts like a web browser, allowing us to make `GET` and `POST` requests to our application's routes.
3.  **`db` Fixture:** This fixture will set up and tear down the in-memory database for each test, ensuring a clean slate. It will also handle creating an initial set of default data (like the master playing strategy) that our tests can rely on.
4.  **`runner` Fixture:** Provides a test runner for invoking our custom Flask CLI commands, such as `init-db`.

#### Step 3: Write "Smoke Tests" (`frontend/tests/test_routes.py`)
The first tests will be simple checks to ensure that all the main pages load correctly.
-   Test that `GET /` redirects to the simulations page.
-   Test that `GET /simulations` returns a `200 OK` status code.
-   Test that all pages in the management blueprint (e.g., `GET /management/players`, `GET /management/casinos`) return `200 OK`.

#### Step 4: Write Tests for CRUD Functionality (`frontend/tests/test_management_crud.py`)
This will be the largest set of tests and will verify every feature we just built. We will write tests for the **Player** model first, then apply the same pattern to the others.
-   **Test `create_player`:**
    1.  Use the `client` to make a `GET` request to `/management/players/new`. Assert the page loads.
    2.  Use the `client` to make a `POST` request to the same URL with valid form data.
    3.  Assert that the response is a redirect to the player list page.
    4.  Follow the redirect and assert that the new player's name appears on the page.
-   **Test `edit_player`:**
    1.  Use the `client` to `POST` a new player.
    2.  Make a `POST` request to the edit URL with updated data.
    3.  Assert that the user is redirected to the list page and that the updated name appears.
-   **Test `delete_player`:**
    1.  Create a new player.
    2.  Make a `POST` request to the delete URL.
    3.  Assert that the user is redirected to the list page and that the player's name is **no longer** on the page.
-   **Test Protections:**
    1.  Write a test to ensure that attempting to access the edit page for the default player results in a redirect and a flash message.
    2.  Write a test to ensure that attempting to `POST` to the delete URL for the default player does not delete the player.

#### Step 5: Write Tests for the Core Simulation Workflow (`frontend/tests/test_simulation.py`)
This test will prove that our Celery "eager mode" strategy works.
1.  Initialize the test database with default data using the `db` fixture.
2.  Use the `client` to make a `POST` request to the `/simulation/1/run_action` URL, simulating a user clicking the "Run Simulation" button.
3.  Because `CELERY_TASK_ALWAYS_EAGER` is on, the simulation task will run immediately. The test will block until it is complete.
4.  Assert that the response is a redirect to the status page.
5.  Follow the redirects until the final results page is loaded.
6.  Assert that the results page contains expected output, such as the player's name and final bankroll.

---

### 4. How to Run the Tests

Once the framework is in place, running the entire test suite will be a single command executed from the project's root directory:

```bash
cd frontend && pytest -v
```

This command will automatically discover and run all the tests in the `frontend/tests/` directory. The `-v` flag provides verbose output.
