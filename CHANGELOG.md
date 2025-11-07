# JOST Project Changelog

This document serves as the project's logbook. It records significant events, architectural decisions, and the evolution of our development process.

---

## 2025-11-07: The "Foundation First" Pivot

### Context
The initial project goal was to implement the Core API for the web service, as defined in the `README.md`. The plan involved a manual, multi-terminal workflow for managing the Gunicorn, Celery, and Redis services.

### Challenge & Test Case
We "tested" this manual workflow by attempting to execute the API verification plan. This test case failed repeatedly, revealing the fragility of our foundational tooling. The primary errors encountered were:
- `ModuleNotFoundError`: A symptom of a lack of contextual integrity.
- `Address already in use`: A symptom of a lack of state management.
- **Log Obscurity**: A symptom of a lack of centralized observability.

### Architectural Decision
The Architect and Builder concluded that the "Level 1" manual workflow had reached its limit (`ErrorRetryLimitExceeded`). In accordance with our "Plan, Then Execute" directive, we **halted** all work on the API.

A new, higher-priority goal was established: to upgrade our development foundation to a robust "Level 2" workflow. This decision was formalized by adding the **"Foundation First" Mandate** to our `airules.md`.

### New Status
- **Obsolete:** The manual, multi-terminal development process.
- **Active:** The implementation of a single, robust `start-services.sh` orchestration script to manage the entire application lifecycle. This script embodies our new development philosophy of stateful, context-aware, and observable tooling.

### Impact
This pivot establishes a stable foundation, enabling us to reliably complete the Core API milestone and accelerate all future development.
