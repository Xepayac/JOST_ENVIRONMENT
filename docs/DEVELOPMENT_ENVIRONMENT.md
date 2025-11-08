# The JOST Development Environment: A Definitive Guide

## 1. Preamble: The "Foundation First" Mandate

This document provides a definitive, highly detailed explanation of our "Level 4" development environment. It is the result of a rigorous debugging and refactoring process, guided by our "Foundation First" mandate. Our environment is now **fully declarative, robust, and idempotent**, representing the stable foundation upon which all future development will be built.

---

## 2. The Core Architecture: An IDX-Native, Declarative System

Our environment is designed to be **IDX-native**. We leverage the built-in features of the Firebase Studio environment to manage our services, rather than fighting the system with external tools like `foreman`.

This architecture is defined by a single file: **`.idx/dev.nix`**. This file is the **single source of truth** for our entire development stack.

### 2.1. Anatomy of `.idx/dev.nix`

Our Nix file is composed of three key sections:

1.  **`packages`**: This section declaratively lists all the system-level binaries our project requires. This includes `python`, `redis`, `gunicorn`, and any other command-line tools. Nix ensures these are always available in the environment.

2.  **`idx.services`**: This is the core of our background service management. We use this **native IDX feature** to define and run our non-interactive processes.
    *   **`redis`**: We enable the built-in Redis service (`services.redis.enable = true;`). This is the most robust way to run Redis, as it's managed directly by the IDX platform.
    *   **`celery`**: We define a custom service for our Celery worker. The command is precisely crafted (`cd service && ../.venv/bin/celery ...`) to ensure it runs with the correct working directory, giving it the proper context to find our Django application modules.

3.  **`idx.previews`**: This native IDX feature is used to define our primary web process.
    *   **`web`**: The command for this preview (`cd service && ../.venv/bin/python manage.py runserver...`) is designed to do two things:
        1.  Run with the correct working directory.
        2.  Use the standard Django development server, whose output is explicitly recognized by the IDX Preview panel, eliminating the timeouts we experienced with Gunicorn.

---

## 3. The "One-Click" Workflow

Our adherence to this IDX-native, declarative model has produced a true "one-click" development workflow.

1.  **On Environment Start/Rebuild:** When the IDX workspace is built, the `.idx/dev.nix` file is processed.
2.  **Services are Launched:** The `idx.services` block automatically starts Redis and the Celery worker in the background.
3.  **Preview is Launched:** The `idx.previews` block automatically starts the Django development server and connects the in-IDE Preview panel to it.

The result is that a developer can go from a fresh rebuild to a fully running, multi-process application with **zero manual steps**.

---

## 4. Standard Operating Procedures

### 4.1. Primary Workflow

*   **To Start the Full Environment:** Rebuild the environment (`Firebase Studio: Hard restart`). This is the definitive way to get a clean, fully operational stack.
*   **To View Logs:** The logs for the `web` process are streamed to the "Preview" panel. The logs for the `celery` and `redis` services can be viewed in the "Services" tab of the IDX side panel.
*   **To Stop the Environment:** Simply close the IDX workspace.

### 4.2. Manual Overrides (for specific tasks)

While the environment is fully automatic, we retain the `start-services.sh` script for specific, one-off tasks.

*   **To Run Migrations:** From the terminal, run `./start-services.sh migrate`. This will correctly activate the virtual environment and run the Django `migrate` command.

This setup is the culmination of our foundational work. It is simple, robust, and directly aligned with the intended workflow of our development platform.
