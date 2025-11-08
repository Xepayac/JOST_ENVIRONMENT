# JOST Blackjack Simulation Platform

Welcome to the JOST project. This is our active, step-by-step action plan.

---

## 1. Documentation Hub

All project knowledge is in our `/docs` directory. Start with `docs/ARCHITECTURE.md`.

*   **[Project Documentation -> `docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)**

---

## 2. Current Status & High-Priority Goal

**Status:** Our "Level 4" environment is stable, and the database tables have been created. However, the database is empty. We have no user accounts to test our authenticated API.

**Next Goal:** Our immediate priority is to **create a user, log in, and perform the final smoke test** to confirm our environment is fully operational.

---

## 3. Action Plan: Final Foundational Step

### [ ] 3.1. Create a Superuser Account

- **Purpose:** To create the first user in our database, which is required to test our authenticated API endpoints.
- **Action:** Use the Django `createsuperuser` management command.
- **Command:** `(cd service && ../.venv/bin/python manage.py createsuperuser)`
- **Instructions:** Follow the prompts to create a username and password.

### [ ] 3.2. Log In to the Application

- **Purpose:** To create an authenticated session so the Developer Workbench can successfully call our API.
- **Action:**
    1.  **Relaunch the preview** (`Firebase Studio: Relaunch preview`).
    2.  In the preview panel, navigate to the `/admin` URL.
    3.  Log in using the superuser credentials you just created.
    4.  After logging in, navigate back to the root URL (`/`) to use the Developer Workbench.

---

## 4. Final Verification

### [ ] 4.1. Perform a Full System Smoke Test

- **Purpose:** To provide definitive proof that our fully configured and initialized pipeline is working correctly.
- **Action:**
    1.  With the Developer Workbench open and your session authenticated, click "Load Defaults."
    2.  Select a profile for each component from the dropdowns.
    3.  Click "Submit Job."
- **Verification:** The simulation will run successfully, and the results will be displayed. This is the final sign-off for Phase 1.
