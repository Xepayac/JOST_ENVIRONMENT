# Git Repository Status

This project utilizes a multi-repository structure, with a main repository and two sub-repositories for the `frontend` and `backend` components.

## Main Repository

*   **Branch:** `main`
*   **Status:** Up to date with `origin/main`.
*   **Uncommitted Changes:**
    *   **Modified:**
        - `.gitignore`
        - `ARCHITECTURE.md`
        - `README.md`
    *   **Untracked:**
        - `backend/` (sub-repository)
        - `frontend/` (sub-repository)
        - `celery.log`
        - `dump.rdb`
        - `todo.md`
        - `worker_tasks.log`

## `backend` Repository

*   **Branch:** `main`
*   **Status:** Up to date with `origin/main`.
*   **Uncommitted Changes:**
    *   **Modified:** Numerous files across the `src/jost_engine` and `tests` directories have been modified. Key changes include modifications to `setup.py` and `docs/README.md`.
    *   **Deleted:** `src/jost_engine/data/betting_strategies/flat_bet.json`
    *   **Untracked:**
        - `requirements.txt`
        - `src/jost_engine.egg-info/`

## `frontend` Repository

*   **Branch:** `main`
*   **Status:** Up to date with `origin/main`.
*   **Uncommitted Changes:**
    *   **Modified:**
        - `blackjack_simulator/app.py`
