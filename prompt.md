# AI Companion Instructions & Project Roadmap

This document outlines the primary objectives for the AI companion and the agreed-upon collaborative model for achieving them.

## 1. Collaboration Model: The "Architect and Builder"

To ensure a productive and safe partnership, we will adhere to the following model:

*   **The User is the Architect:** You are responsible for the high-level design, architectural decisions, and final approval of work. Your expertise is in making the "Why" and "What" decisions.
*   **The AI is the Builder:** I am responsible for executing your plans, generating boilerplate code, writing tests, and handling the meticulous "How" of implementation.

I am also responsible for continually monitoring this file for changes and marking items as complete (`[X]`) as we finish them.

## 2. Immediate Objective: Implement the "Simple Messenger" Architecture

Our top priority is to refactor the simulation workflow to be more robust and scalable, permanently fixing the issues with the Celery worker. This plan, "The Simple Messenger," simplifies the worker's role and creates a clear, database-centric data flow.

### Implementation To-Do List:

- [ ] **1. Create the `SimulationJob` Model:**
    - **Action:** In `frontend/simulator/models.py`, create a new model, `SimulationJob`.
    - **Fields:** `job_id` (UUIDField), `user_id`, `status` (CharField), `request_data` (JSONField for the input), and `result_data` (JSONField for the output).
    - **Action:** Create and run the database migrations for this new model.

- [ ] **2. Refactor the `jost_engine`:**
    - **Action:** In `backend/src/jost_engine/main.py`, create a new function, `run_simulation_from_db(job_id)`.
    - **Details:** This function will connect to the Django database, fetch the `SimulationJob` record using the `job_id`, run the simulation with the `request_data`, and save the results back to the `result_data` field.

- [ ] **3. Simplify the Celery Task:**
    - **Action:** Rewrite the `run_jost_simulation_task` in `frontend/simulator/tasks.py`.
    - **Details:** Its only job will be to import and call `run_simulation_from_db(job_id)`.

- [ ] **4. Update the Django View:**
    - **Action:** Modify the `simulation_form` and `run_default_simulation` views in `frontend/simulator/views.py`.
    - **Details:** These views will now create a `SimulationJob` object (instead of a `Simulation` object) and pass the new `job_id` to the Celery task.

- [ ] **5. Update the Results Page:**
    - **Action:** Modify the `simulation_result` view and template.
    - **Details:** They will now fetch and display the data from the `SimulationJob` model.
