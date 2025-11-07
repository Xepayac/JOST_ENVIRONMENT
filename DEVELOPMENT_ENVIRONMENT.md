# The JOST Project Development Environment

## Preamble: The "Foundation First" Pivot

This document describes the architecture of our "Level 2" development environment. It is the direct result of a strategic pivot made in accordance with our "Foundation First" mandate (`airules.md`).

Our initial "Level 1" workflow was a fragile, manual process that required managing multiple services in separate terminals. This led to a consistent pattern of environmental friction (`ModuleNotFoundError`, `Address already in use`). We halted all application development to address this foundational weakness.

The result is the robust, script-based orchestration system detailed below. This document explains not only *what* our environment is, but *why* it is designed this way.

---

## 1. The Ideal Architecture: The "Three Layers" of a Declarative Environment

Our initial goal was to create a fully declarative, container-based development environment. This ideal architecture consists of three distinct layers:

1.  **The Workspace Foundation (Nix):** The `.idx/dev.nix` file's responsibility is to declaratively install all the *system-level tools* and binaries needed for the project into the IDX workspace.
2.  **The Application Blueprint (Dockerfile):** The `Dockerfile`'s responsibility is to be the blueprint for a single, portable, and reproducible image of our application.
3.  **The Orchestrator (Docker Compose):** The `docker-compose.yml` file's responsibility is to take the application blueprint and define how to run it as a complete, multi-service system.

---

## 2. Critical Constraint: The Firebase IDX Environment and Docker

During the implementation of this ideal architecture, we discovered a critical environmental constraint: **The Docker daemon is not accessible within the Firebase IDX workspace.**

Our attempts to use `docker-compose` failed because it could not connect to the Docker socket. We do not have the necessary system-level permissions to start the Docker daemon manually.

**Memo to the Next AI/Developer:** Do not waste time attempting to use Docker or `docker-compose` directly in this environment. The current IDX workspace is not configured to support it.

---

## 3. The Pragmatic and Robust Solution: The Orchestration Script

In response to this constraint, we engineered a solution that achieves the *principles* of a declarative environment using the tools we have available. The `start-services.sh` script is our project's **service orchestrator**.

This script is a direct implementation of our "Level 2" development philosophy:

*   **Stateful & Context-Aware:** The script uses PID files in a `.run/` directory to manage state and correctly sets the `PYTHONPATH` to ensure contextual integrity. This permanently solves `Address already in use` and `ModuleNotFoundError` errors.
*   **Native Observability:** The script uses the native logging capabilities of each service to direct all output to a central `logs/` directory.
*   **Graceful Shutdowns:** The `stop` command performs a professional "polite-then-forceful" (SIGTERM-then-SIGKILL) shutdown to ensure a clean state.
*   **A Single "Command API":** This script is now the single entry point for managing the entire application stack.

---

## 4. Standard Operating Procedures (The "Command API")

The following commands are the new, official way to work on this project.

*   **To Start All Services:** `./start-services.sh start`
*   **To Stop All Services:** `./start-services.sh stop`
*   **To Restart All Services:** `./start-services.sh restart`
*   **To Check Service Status:** `./start-services.sh status`
*   **To View All Logs (Streaming):** `./start-services.sh logs`
*   **To Run Migrations Manually:** `./start-services.sh migrate`

---

## 5. Future Development of the Environment

*   **Medium-Term (Investigation):** We should investigate if Firebase IDX provides its own native, built-in mechanism for running and managing background services. If such a feature exists, it may be a more platform-idiomatic solution than our custom script.
*   **Long-Term (Production Alignment):** Our ultimate goal is to deploy this service to a production environment like **Google Cloud Run**. The `Dockerfile` we created remains a valuable asset for this. Future work will involve adapting our application to be deployed as a container to Cloud Run.
