# AI Companion Instructions & Project Roadmap

## 1. Collaboration Model: The "Architect and Builder"

To ensure a productive and safe partnership, we will adhere to the following model:

*   **The User is the Architect:** You are responsible for the high-level design, architectural decisions, and final approval of work. Your expertise is in making the "Why" and "What" decisions.
*   **The AI is the Builder:** I am responsible for executing your plans, generating boilerplate code, writing tests, and handling the meticulous "How" of implementation.

I am also responsible for continually monitoring this file for changes and marking items as complete (`[X]`) as we finish them.

## 2. Project Status & Recent Updates

*   **Environment Cleanup:** The development environment has been thoroughly cleaned.
    *   Removed old, empty Celery log files (`celery.log`, `celery_worker.log`).
    *   Deleted the entire `logs` directory which contained irrelevant error logs from the previous Flask application.
*   **Configuration Update:**
    *   The `wsgi.py` file has been corrected to properly point to our Django application. This was a critical fix to ensure any WSGI-compliant server (like the Django development server or Gunicorn) can find and run the project.

This provides a clean and correctly configured foundation for proceeding with our Django development tasks.

## 3. Immediate Objective: Implement the "Simple Messenger" Architecture

Our top priority is to build out the Django frontend to implement the "Simple Messenger" workflow. Since we are starting from a clean slate after deleting the previous frontend, we will be creating all necessary files and directories from scratch.

### Implementation To-Do List (From Scratch):

- [ ] **1. Create the Django App:**
    - **Action:** Inside the `frontend` directory, create a new Django app named `simulator`.
    - **Command:** `python manage.py startapp simulator`

- [ ] **2. Create the `SimulationJob` Model:**
    - **Action:** In the newly created `frontend/simulator/models.py`, define the `SimulationJob` model.
    - **Fields:** `job_id` (UUIDField, primary_key=True), `user` (ForeignKey to User model), `status` (CharField), `request_data` (JSONField), and `result_data` (JSONField, null=True, blank=True).
    - **Action:** Add the new `simulator` app to the `INSTALLED_APPS` list in `frontend/frontend/settings.py`.

- [ ] **3. Create and Run Database Migrations:**
    - **Action:** Generate the database migration file for the new `SimulationJob` model.
    - **Command:** `python manage.py makemigrations simulator`
    - **Action:** Apply the migration to the database.
    - **Command:** `python manage.py migrate`

- [ ] **4. Refactor the `jost_engine`:**
    - **Action:** In `backend/src/jost_engine/main.py`, create a new function, `run_simulation_from_db(job_id)`.
    - **Details:** This function will contain the logic to connect to the Django database, fetch the `SimulationJob` record using the `job_id`, run the simulation with the `request_data`, and save the results back to the `result_data` field.

- [ ] **5. Create the Celery Task:**
    - **Action:** Create a new file `frontend/simulator/tasks.py` and define the Celery task `run_jost_simulation_task`.
    - **Details:** Its only job will be to import and call `run_simulation_from_db(job_id)`.

- [ ] **6. Create the Django Views:**
    - **Action:** In `frontend/simulator/views.py`, create the views needed for the simulation workflow.
    - **Views to Create:**
        - `simulation_form`: A view to display the form for starting a new simulation.
        - `run_default_simulation`: A view to handle the form submission. This view will create a `SimulationJob` object in the database and then dispatch the Celery task with the new `job_id`.
        - `simulation_result`: A view to display the results of a completed simulation, fetching the data from the `SimulationJob` model using the `job_id`.

- [ ] **7. Create URL Routing:**
    - **Action:** Create a new file `frontend/simulator/urls.py` to define the URL patterns for the `simulator` app's views.
    - **Action:** Include the `simulator.urls` in the main `frontend/frontend/urls.py` file.

- [ ] **8. Create the HTML Templates:**
    - **Action:** Create a `frontend/simulator/templates/simulator` directory.
    - **Templates to Create:**
        - `simulation_form.html`: A template with a simple form and a button to trigger the `run_default_simulation` view.
        - `simulation_result.html`: A template to display the simulation results stored in the `result_data` field of the `SimulationJob` model.
