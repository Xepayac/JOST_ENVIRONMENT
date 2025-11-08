# Developer Onboarding Guide

## 1. Welcome to the JOST Project

This guide provides the exact, step-by-step instructions to get the JOST Blackjack Simulation Platform running on your local development machine. Our "Level 4" environment is fully declarative and automated.

---

## 2. Prerequisites

*   You must be working within the **Firebase IDX environment**.
*   You have `git` installed and have cloned the project repository, including its submodules.

---

## 3. The "One-Click" Setup Procedure

Our environment is managed declaratively through the `.idx/dev.nix` file. This file automatically configures and launches our entire application stack. There is only one manual step required to get a fully operational environment.

### The Only Step: Rebuild the Environment

To start the entire application stack (Redis, Celery, and the Django Web Server), you simply need to build or rebuild the IDX environment.

1.  Open the **Command Palette** (Cmd+Shift+P on Mac, Ctrl+Shift+P on other systems).
2.  Search for and run the command: **`Firebase Studio: Hard restart`**.
3.  A notification will appear: "Environment config updated". Click the **"Rebuild environment"** button.

**That's it.** Upon a successful rebuild, the following will happen automatically:
*   The **Redis** server will start.
*   The **Celery worker** will start.
*   The **Django web server** will start.
*   The **IDX Preview panel** will open and connect to the web server, displaying the Developer Workbench.

---

## 4. Smoke Test: Verifying Your Installation

Once the environment is running, you can perform a simple smoke test to confirm that every component of the system is working correctly.

1.  In the **IDX Preview panel**, which should be displaying the Developer Workbench, click the **"Load Defaults"** button.
2.  **Verify** that the "Reference Defaults" column populates with JSON data.
3.  Click the **"Submit Job"** button.
4.  **Monitor** the "Job Results" column.

**Verification:** The "Job Results" column will transition from `Submitting job...` to `Job status: PENDING...`, `Job status: RUNNING...`, and finally display the complete, formatted JSON output of the simulation.

If you see the final JSON results, your environment is **fully operational and verified**.

---

## 5. Next Steps

You are now ready to begin development. For specific one-off tasks, you can use the terminal:

*   **To Run Migrations:** `./start-services.sh migrate`

Welcome to the team.
