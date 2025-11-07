# JOST Blackjack Simulation Platform

Welcome to the JOST project. This `README.md` is the official entry point. It outlines our current development goals and provides a map to our comprehensive documentation.

---

## 1. The "Pyramid of Knowledge": Our Documentation Hub

All project knowledge is centrally located in our `/docs` directory. The best place to start is our architectural blueprint.

*   **[Project Documentation -> `docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)**

---

## 2. Current Status & High-Priority Goal

**Status:** The major refactoring of the web service is complete. The codebase is now aligned with our stateless, "local-first" architecture.

**Next Goal:** Before moving to the next phase, we must perform critical administrative and verification tasks to formally close out Phase 1 and ensure the system is robust.

---

## 3. Action Plan: Phase 1 Verification and Housekeeping

### [ ] 3.1. Add and Commit All Changes

- **Purpose:** To save all our recent refactoring work to the project's version control history.
- **Action:** Add all changed files to the staging area and create a commit.
- **Command 1:** `git add .`
- **Command 2:** `git commit -m "feat: complete stateless refactor and build developer workbench"`
- **Verification:** The `git status` command will show a clean working tree.

### [ ] 3.2. Perform a Full System Smoke Test

- **Purpose:** To provide definitive proof that the entire backend pipeline is working correctly and robustly. This is the final quality gate for Phase 1.
- **Action:** We will use our new Developer Workbench to perform a complete, end-to-end test.
    1.  Ensure all services are running with `./start-services.sh start`.
    2.  Open the Developer Workbench in the browser (at the `/` URL).
    3.  Click the "Load Defaults" button and verify that the reference column populates.
    4.  Click the "Submit Job" button to run the pre-filled default simulation.
    5.  Monitor the "Job Results" column.
- **Verification:** The "Job Results" column must successfully transition from `Submitting job...` to `Job status: PENDING...` to `Job status: RUNNING...` and finally display the complete, formatted JSON output of the simulation. This successful result is the final sign-off for Phase 1.

---

## 4. Next Major Goal: Building the `user_terminal`

Once the verification steps above are complete, we will begin **Phase 2:** the development of the `user_terminal`.

---

## 5. Standard Operating Procedures

- **To Start All Services:** `./start-services.sh start`
- **To Stop All Services:** `./start-services.sh stop`
- **To Check Service Status:** `./start-services.sh status`
- **To Run Migrations:** `./start-services.sh migrate`
