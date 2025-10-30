# Project TODO List

This file tracks specific, granular tasks for the development team.

## Phase 1: Strengthen Backend & Configuration

- [x] **Strengthen Database: Refactor Application Core**
    - [x] **Decouple Configuration:**
        - [x] Add `python-dotenv` to `requirements.txt`.
        - [x] Create a `.env` file for `FLASK_APP`, `SECRET_KEY`, and `DATABASE_URL`.
        - [x] Create a `config.py` to load and manage configuration from environment variables.
    - [x] **Implement Application Factory Pattern:**
        - [x] Restructure `frontend/blackjack_simulator/app.py` into a `create_app` function.
        - [x] Move database and other extension initializations inside the factory.
    - [x] **Separate Database Initialization:**
        - [x] Move the `load_default_data` logic into a new, dedicated CLI command (`flask init-db`).
        - [x] Register the new command within the application factory.
- [x] **Verify CLI Functionality**
- [x] **Make sure the program works** - *Core functionality restored after race condition fix.*
- [x] **Consolidate JSON Files to a Single Source of Truth.** - *Decision made to use the main database as the single source of truth. The Celery worker will now generate temporary JSON files on-the-fly for each simulation run, mimicking the structure of the "perfect file" examples that remain within the `jost_engine` project. This ensures the engine stays decoupled while eliminating data duplication.*
- [X] **Generate "Perfect Example" Strategy Files**
    - [X] Create `generate_strategies.py` script to run the strategy generator.
    - [X] Generate H17 (Hits on Soft 17) strategy file.
    - [X] Generate S17 (Stands on Soft 17) strategy file.
- [X] **Refactor `jost_engine` for Clarity and Testability**
    - [X] **Add End-to-End Integration Test:** Create a new test file (`backend/tests/test_integration.py`) that runs a full simulation using real data files to ensure the engine works from end to end.
    - [X] **Curate "Perfect Example" JSON Files:** Create a minimal, high-quality set of reference files for players, casinos, and strategies, establishing a clear data contract for the engine.
    - [X] **Update and Finalize Integration Test:** Modify the new integration test to use the newly created "perfect example" files.
    - [X] **Clean Up Legacy Data Files:** Delete the numerous old and redundant JSON files from the `jost_engine/data` directory.
- [X] **Refine CLI for Flexibility and Scripting (Future Enhancement)**
    - [X] **Decision:** For now, the interactive CLI (`main.py`) will be maintained as it serves as an effective "sales piece" for demonstrating the engine's capabilities. The following items are planned for a future refactor.
- [ ] **Harden Backend Test Strategy:** Review the existing backend tests in `backend/tests`. Identify and add tests for edge cases and more complex simulation scenarios.

## Phase 2: Enhance Frontend Application

This phase focuses on building out the user-facing features and improving the application's quality. For more context, see the Project Roadmap section in `.idx/ARCHITECTURE.md`.

- [x] **Fix Core Simulation Functionality:** - *The simulation was failing due to a series of data structure and serialization issues. This has been resolved.*
- [x] **Implement Hand History Feature:**
    - [x] Add `hand_history` column to the `Result` model.
    - [x] Add a checkbox to the simulation page to enable/disable hand history logging.
    - [x] Update the backend to handle the new `log_hands` parameter.
    - [x] Add a download button to the results page to download the hand history.
- [X] **Improve Visual Design:**
    - [X] Research and select a lightweight CSS framework (e.g., Bootstrap, Bulma) to apply a clean and modern design to the application templates.
    - [X] Redesign the layout of the simulation configuration and results pages for better readability and user experience.

- [x] **Implement CRUD for Core Entities:**
    - [x] **Establish Foundation:**
        - [x] Create a new Flask Blueprint for management (`management_bp`) in a new file: `frontend/blackjack_simulator/management.py`.
        - [x] Register the new blueprint in the application factory in `app.py`.
        - [x] Add navigation links to the main layout (`layout.html`) to access the new management pages.
    - [x] **Build Player Management:** (Simplest First)
        - [x] Create a Flask-WTF form for the `Player` model.
        - [x] Build the "List Players" page (`/management/players`).
        - [x] Build the "Create Player" page (`/management/players/new`) and handle form submission.
        - [x] Build the "Edit Player" page (`/management/players/<id>/edit`) and handle form submission.
        - [x] Implement the "Delete Player" functionality.
    - [x] **Build Casino Management:**
        - [x] Create a Flask-WTF form for the `Casino` model (handling boolean fields with checkboxes).
        - [x] Build the "List Casinos" page.
        - [x] Build the "Create Casino" page.
        - [x] Build the "Edit Casino" page.
        - [x] Implement the "Delete Casino" functionality.
    - [x] **Build Betting Strategy Management:**
        - [x] Create a Flask-WTF form for the `BettingStrategy` model.
        - [x] Use a `TextAreaField` for the `bet_ramp` JSON data.
        - [x] **Crucial:** Add a custom validator to the form to ensure the text in the `bet_ramp` field is valid JSON and matches the expected data structure (a dictionary of string keys to number values, e.g., `{"1": 10, "2": 50}`). This prevents bad data from entering the database.
        - [x] Build the "List Betting Strategies" page.
        - [x] Build the "Create Betting Strategy" page.
        - [x] Build the "Edit Betting Strategy" page.
        - [x] Implement the "Delete Betting Strategy" functionality.
    - [x] **Build Playing Strategy Management:** (Most Complex)
        - [x] Create a Flask-WTF form for the `PlayingStrategy` model.
        - [x] Use three separate `TextAreaField`s for `hard_total_actions`, `soft_total_actions`, and `pair_splitting_actions`.
        - [x] **Crucial:** Add custom validators for each of the three text areas to ensure the input is valid JSON and matches the complex nested structure expected by the simulation engine. This is the most critical validation step to ensure the application remains stable.
        - [x] Build the "List Playing Strategies" page.
        - [x] Build the "Create Playing Strategy" page.
        - [x] Build the "Edit Playing Strategy" page.
        - [x] Implement the "Delete Playing Strategy" functionality.

- [x] **Develop Frontend Test Strategy:**
    - [x] Research and decide on a testing framework for Flask applications (e.g., Pytest with `pytest-flask`).
    - [x] Write initial tests for critical frontend routes, such as form submissions and API endpoints.
    - [X] Write tests for edge cases and incorrect files when building files. 
    - [X] Write a full suite of pytests guided py pytest-cov
- [ ] **Game Hardening and Quality of Experience upgrades:**
    - [ ] Ensure master players use two hands
    - [ ] Have the code conventions be the same across all experiences, u = surrender and similar situations. 
    - [ ] Ensure that all changes to user variables are being saved in the database. 
    -[ ] Create testing for these new abilities. 
    - [ ] **Create the ability to run Spanish21 simulations:**
    - [ ] Ensure master casinos in backend have Insurance, Later Surrender and Early Surrender. 
    - [ ] Ensure MASTER strategies in the backend are early surrender", "late surrender" and take "insurance strategies". 
- [ ] **Game Hardening and Quality of Experience upgrades:**
    - [ ] Create all the rules in the backend for runing Spanish 21 simulations
    - [ ] Create all the changes in the front end and database for running Spanish 21 simulations
    - [ ] Create an improved interface for betting strategies. 
    - [ ] Create an AI interface for betting strategies
    - [ ] Push data to Jupyter book and set up Jupyter book for analyzing play
    - [ ] In results, give as much information that you can give with the default information. money per hour, N0, Percent chance of loss?
    - [ ] Strengthen test strategy for backend. Run pytest-cov to 95%
- [ ] **Switch to Django database.:**