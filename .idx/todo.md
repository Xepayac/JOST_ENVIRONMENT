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
- [ ] **Generate "Perfect Example" Strategy Files**
    - [ ] Create `generate_strategies.py` script to run the strategy generator.
    - [ ] Generate H17 (Hits on Soft 17) strategy file.
    - [ ] Generate S17 (Stands on Soft 17) strategy file.
- [ ] **Refactor `jost_engine` for Clarity and Testability**
    - [ ] **Add End-to-End Integration Test:** Create a new test file (`backend/tests/test_integration.py`) that runs a full simulation using real data files to ensure the engine works from end to end.
    - [ ] **Curate "Perfect Example" JSON Files:** Create a minimal, high-quality set of reference files for players, casinos, and strategies, establishing a clear data contract for the engine.
    - [ ] **Update and Finalize Integration Test:** Modify the new integration test to use the newly created "perfect example" files.
    - [ ] **Clean Up Legacy Data Files:** Delete the numerous old and redundant JSON files from the `jost_engine/data` directory.
- [ ] **Harden Backend Test Strategy:** Review the existing backend tests in `backend/tests`. Identify and add tests for edge cases and more complex simulation scenarios.

## Phase 2: Enhance Frontend Application

This phase focuses on building out the user-facing features and improving the application's quality. For more context, see the Project Roadmap section in `.idx/ARCHITECTURE.md`.

- [ ] **Improve Visual Design:**
    - [ ] Research and select a lightweight CSS framework (e.g., Bootstrap, Bulma) to apply a clean and modern design to the application templates.
    - [ ] Redesign the layout of the simulation configuration and results pages for better readability and user experience.

- [ ] **Implement CRUD for Core Entities:**
    - [ ] Create a new Flask Blueprint for managing application entities.
    - [ ] Build a web interface (routes, templates, and forms) to allow users to **Create, Read, Update, and Delete** the following:
        - [ ] Players
        - [ ] Casinos
        - [ ] Betting Strategies
        - [ ] Playing Strategies

- [ ] **Develop Frontend Test Strategy:**
    - [ ] Research and decide on a testing framework for Flask applications (e.g., Pytest with `pytest-flask`).
    - [ ] Write initial tests for critical frontend routes, such as form submissions and API endpoints.
