# Frontend Test Strategy & Requirements

This document outlines the testing strategy for the Flask-based frontend of the Jost Engine Blackjack Simulator. The goal is to ensure the user interface is reliable, intuitive, and correctly integrated with the backend simulation engine.

## 1. Unit & Integration Testing (Pytest)

We will use Pytest with `pytest-flask` to test the frontend components.

### Requirements:

-   **[x] Test Setup (`conftest.py`):**
    -   **[x]** Create a fixture to initialize the Flask test client.
    -   **[x]** Create a fixture to provide a test instance of the Celery app for task testing.
    -   **[x]** Create fixtures that mock the backend `jost_engine` or provide pre-canned simulation results to isolate frontend tests from the full simulation logic.

-   **[x] Route & View Tests (`tests/test_app.py`, `tests/test_simulation.py`):**
    -   **[x]** Test that all main routes (`/`, `/simulations`, `/management`, etc.) return a `200 OK` status.
    -   **[x]** Test that the `run_simulation` route correctly receives form data and triggers the Celery task.
    -   **[x]** Test that the `simulation_status` route correctly reports the status of a running/completed task.
    -   **[x]** Test that the `result_details` route displays data correctly for a given simulation ID.

-   **[x] Form Validation Tests (`tests/test_forms.py`):**
    -   **[x]** Test that all WTForms (e.g., `SimulationForm`, `CasinoForm`) correctly validate valid and invalid input.
    -   **[x]** Test for CSRF protection. _(Note: CSRF is implicitly tested by making valid POST requests, but explicit tests could be added)._

-   **[x] CRUD Operation Tests (`tests/test_management_crud.py`):**
    -   **[x]** Test creating, reading, updating, and deleting each type of management object (Casinos, Players, Playing Strategies, Betting Strategies).
    -   **[x]** Verify that changes are correctly saved to the underlying JSON files.

## 2. End-to-End (E2E) Testing (Robo Script)

For E2E testing, we will use Firebase Test Lab's Robo Script to simulate user interactions in a real browser environment.

These scripts are written in JSON and can be recorded using the Firebase Test Lab tools in Android Studio or written manually. They guide the Robo test, allowing it to perform a series of user actions and assertions.

_**Note:** For these scripts to work, the corresponding HTML elements must have the `resourceId` (or another unique descriptor) specified in the script. This may require adding `id` attributes to your HTML elements._

### Requirements:

-   **[x] Basic Navigation Script:**
    -   Create a Robo Script that navigates through the main pages of the application:
        -   Home page -> Simulations page
        -   Home page -> Management page
        -   Management page -> Casinos, Players, Strategies pages.
    -   Assert that the correct page titles or key elements are present.

    ```json
    [
      {
        "crawlStage": "crawl",
        "actions": [
          {
            "actionId": "Click_Simulations_Link",
            "eventType": "VIEW_CLICKED",
            "elementDescriptors": [
              { "resourceId": "simulations-link" }
            ]
          },
          {
            "actionId": "Assert_Simulations_Page",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "text": "Simulations" }
            ]
          },
          {
            "actionId": "Go_Back_1",
            "eventType": "GO_BACK"
          },
          {
            "actionId": "Click_Management_Link",
            "eventType": "VIEW_CLICKED",
            "elementDescriptors": [
              { "resourceId": "management-link" }
            ]
          },
          {
            "actionId": "Assert_Management_Page",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "text": "Management" }
            ]
          },
          {
            "actionId": "Click_Casinos_Button",
            "eventType": "VIEW_CLICKED",
            "elementDescriptors": [
              { "text": "Casinos" }
            ]
          },
          {
            "actionId": "Assert_Casinos_Page",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "text": "Manage Casinos" }
            ]
          }
        ]
      }
    ]
    ```

-   **[x] Simulation Workflow Script:**
    -   Create a Robo Script that:
        1.  Navigates to the "New Simulation" page.
        2.  Fills out the simulation form with default values.
        3.  Submits the form.
        4.  Polls the status page until the simulation is complete.
        5.  Navigates to the results page and verifies that a results graph or table is displayed.

    ```json
    [
      {
        "crawlStage": "crawl",
        "actions": [
          {
            "actionId": "Navigate_To_New_Simulation",
            "eventType": "VIEW_CLICKED",
            "elementDescriptors": [
              { "resourceId": "new-simulation-link" }
            ]
          },
          {
            "actionId": "Input_Simulation_Title",
            "eventType": "TEXT_CHANGED",
            "replacementText": "E2E Robo Test",
            "elementDescriptors": [
              { "resourceId": "simulation-title-input" }
            ]
          },
          {
            "actionId": "Click_Run_Simulation",
            "eventType": "VIEW_CLICKED",
            "elementDescriptors": [
              { "resourceId": "run-simulation-button" }
            ]
          },
          {
            "actionId": "Assert_Status_Page",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "text": "Simulation in Progress..." }
            ]
          },
          {
            "actionId": "Wait_For_Simulation",
            "sleepTime": 15
          },
          {
            "actionId": "Assert_Results_Page",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "text": "Results for E2E Robo Test" }
            ]
          },
          {
            "actionId": "Assert_Graph_Is_Present",
            "eventType": "ASSERTION",
            "elementDescriptors": [
              { "resourceId": "results-chart" }
            ]
          }
        ]
      }
    ]
    ```
