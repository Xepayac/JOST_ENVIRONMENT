# Project Architecture: Blackjack Simulation Platform

## 1. Executive Summary

This document provides a comprehensive overview of the technical architecture for the JOST Blackjack Simulation Platform. The system is designed as a modern web application that allows users to configure and run computationally intensive Blackjack simulations and view the results.

The application is currently undergoing a strategic migration from a Flask-based frontend to a more robust, "batteries-included" **Django** framework. This migration is the project's top priority, intended to solve recurring issues with asynchronous task management and create a more stable, maintainable, and scalable foundation for future development.

---

## 2. High-Level Architectural View

The platform is built on a three-tier architecture composed of distinct, cooperating services:

1.  **The Frontend (Web Server):** A **Django** application served by Gunicorn. This is the user's entry point to the system, handling user authentication, data management, and the user interface.
2.  **The Asynchronous Backbone (Task Queue):** A Celery distributed task queue using a Redis server as its broker and result backend. This is essential for offloading long-running simulations from the web server.
3.  **The Backend (Simulation Engine):** A pure Python library (`jost_engine`) that runs the simulations. It is a standalone package with no knowledge of the web framework.

---

## 3. Visual Architecture Diagram

```
+----------+      (HTTP)      +-----------+      (WSGI)      +-----------------+
|          | ---------------->|           | ---------------->|                 |
| Browser  |                  | Gunicorn  |                  |  Django Web App |
|          | <----------------|           | <----------------|   (simulator)   |
+----------+      (HTML)      +-----------+      (Redirect)  +-----------------+
    ^   |                                                        |           ^
    |   | (Polling API)                                          | (Task)    | (ORM DB I/O)
    |   v                                                        v           |
+----------+      (Broker/Result)      +-----------------+<--+----------+
|          | <------------------------>|                 |   | db.sqlite3|
|  Redis   |                           |  Celery Worker  |   |           |
|          | <------------------------>|                 |   +----------+
+----------+                           +-----------------+
                                               |
                                               v (Writes .json file)
                                         +-------------------+
                                         | celery_profiles/  |
                                         +-------------------+
                                               | (Reads .json file)
                                         +-------------+
                                         |             |
                                         | jost_engine |
                                         |             |
                                         +-------------+
```

---

## 4. Developer Quickstart Guide (Django)

1.  **Activate the Environment:** Source the Nix-managed virtual environment: `source .venv/bin/activate`.
2.  **Navigate to Frontend:** All commands must be run from the `frontend` directory: `cd frontend`.
3.  **Apply Database Migrations:** Ensure the database schema is up to date with the models: `python manage.py migrate`.
4.  **Create a Superuser:** To access the Django Admin, create an administrator account: `python manage.py createsuperuser`.
5.  **Run the Development Server:** Execute `./start-dev.sh`. This script handles starting Redis, the Celery worker, and the Django development server in the correct order.
6.  **Access the Application:**
    *   **Web Interface:** Open your browser to the development URL.
    *   **Admin Panel:** Access the admin interface at `/admin` to manage all database entities.

---

## 5. Component Deep Dive
(Sections on Gunicorn, Django, Database, Celery, Redis, and jost_engine)

---

## 6. The Communication Flow
(Step-by-step description of a simulation run)

---

## 7. Architectural Challenge: The Frontend-Backend Data Contract

During the migration to Django, a significant architectural challenge was identified: the data contract between the frontend web application and the backend `jost_engine`.

### The Problem

The `jost_engine` is designed as a self-contained Python library. It expects to load its configuration—for casinos, players, and strategies—from `.json` files located within its own `data` directory. Early attempts to refactor the system involved the frontend's Celery worker trying to bypass this file-based system by directly injecting data (as Python dictionaries) into the engine's functions. This approach led to a cascade of persistent, hard-to-debug errors because it violated the engine's core design principle.

### The Core Principle: Simulation Integrity via JSON Files

The `jost_engine`'s reliance on `.json` files is a deliberate design choice to guarantee **simulation integrity and reproducibility**. For a simulation to be a valid scientific experiment, its inputs must be precise, version-controlled, and immutable. A `.json` file serves as a perfect, self-contained record of the exact parameters (casino rules, player strategy, etc.) used for a given run.

Passing in-memory Python objects directly to the engine is brittle. It creates a tight coupling between the frontend and backend and makes it impossible to guarantee that the simulation is being run with the exact, intended strategy. The `.json` file acts as the "single source of truth" for a simulation's parameters.

### The Solution: The "Temporary File Bridge"

The final, correct architecture embraces the `jost_engine`'s file-based nature while still allowing the frontend to manage custom data in its database. This is achieved through a "temporary file bridge" orchestrated by the Celery worker.

1.  **Dedicated "Celery Profiles" Directory:** A new directory, `backend/src/jost_engine/data/celery_profiles`, was created. This acts as a "sandbox" or "inbox" for the frontend to place temporary simulation configurations.

2.  **Modified Engine (`config_manager.py`):** The `jost_engine`'s file loader was modified to be aware of this new directory. It now searches for profiles in a specific order of priority:
    1.  `celery_profiles/` (for simulation-specific, temporary files)
    2.  `custom/` (for user-saved, permanent custom profiles)
    3.  `default/` (for the master, fallback profiles)

3.  **The Data Flow:** When a user runs a simulation from the web interface:
    a.  The Django view triggers a Celery task.
    b.  The Celery task retrieves the required data (for the casino, player, and strategies) from the Django database.
    c.  The task calls the `jost_engine`'s `save_profile` function, which writes the data from the database into a new, uniquely named `.json` file inside the `celery_profiles` directory.
    d.  The task then calls the `setup_game_from_config` function, passing it the *name* of the temporary file it just created.
    e.  The `jost_engine` finds and loads this exact `.json` file, ensuring perfect fidelity.
    f.  After the simulation is complete, the Celery task calls `delete_profile` to clean up the temporary file.

This architecture is robust and clean. It correctly uses the backend's file-based system while providing a dedicated, isolated channel for the frontend to communicate with it, resolving the data contract issues permanently.

---

## 8. Project Roadmap and Future Work
(Sections on future work and the project roadmap)
