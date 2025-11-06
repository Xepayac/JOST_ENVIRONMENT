# JOST Blackjack Simulation Platform

## 1. Project Overview

This document serves as the primary action plan for the development of the JOST Web Service. For a full architectural overview, please see `ARCHITECTURE.md`.

## 2. Current Status & New Architectural Direction

Our backend is functional. We will now build the two core interfaces for the Web Service: its primary API (for the `user_terminal`) and its secondary Developer Dashboard (for our own testing and diagnostics).

---

## 3. Current Objective: Build a Production-Ready Web Service

### Phase 1: Build the Core API (Priority #1)

- [ ] **1. Integrate Django REST Framework**
    -   **Action:** Add `djangorestframework` to our `.idx/dev.nix` file and to `INSTALLED_APPS`.

- [ ] **2. Build the API Endpoints**
    -   **Purpose:** To create the programmatic endpoints for submitting jobs and retrieving results.
    -   **Action 2.A:** Create `service/simulator/serializers.py` to define how `SimulationJob` objects are converted to and from JSON.
    -   **Action 2.B:** Create a new `service/api/` app to house all API-specific logic.
    -   **Action 2.C:** In the new app's `views.py`, create API views for:
        *   `POST /api/v1/jobs/`: Submitting a new simulation job.
        *   `GET /api/v1/jobs/{job_id}/`: Checking the status and retrieving the results of a job.
    -   **Action 2.D:** Configure the URL routing for these new endpoints.

- [ ] **3. Secure the API**
    -   **Purpose:** To ensure that only authenticated `user_terminal`s can use the service.
    -   **Action:** Implement Token Authentication using DRF's built-in system.

### Phase 2: Build the Developer Dashboard (A Simple Sanity Check)

- [ ] **4. Build the "Raw JSON Runner"**
    -   **Purpose:** To provide a simple tool for developers to test the service pipeline with a master simulation file or custom JSON.
    -   **Action 4.A:** Create a `data/test_scenarios/` directory.
    -   **Action 4.B:** In that directory, create a single `master_simulation.json` file.
    -   **Action 4.C:** Create a simple `developer_dashboard` view and template. The template will contain a button ("Load Master Simulation"), a `<textarea>`, and a "Submit" button.
    -   **Action 4.D:** The form will `POST` to a `create_simulation` view, which will create the job and dispatch the task.

- [ ] **5. Build a Basic Job History View**
    -   **Purpose:** To give developers a simple list of the most recent jobs and their statuses.
    -   **Action:** Create a `simulation_list` view and template to display the latest `SimulationJob` objects in a simple table.
