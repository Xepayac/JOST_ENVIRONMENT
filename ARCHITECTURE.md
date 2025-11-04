# Architectural Plan: The JOST Blackjack Product Ecosystem

## 1. Executive Summary & Vision

This document outlines the definitive architectural plan for the JOST Blackjack product ecosystem. This architecture is designed to support a suite of interconnected applications, ensure scientific integrity, protect user data sovereignty, and provide a scalable, commercial-grade backend.

**The Vision:** To create a unified platform where a user has a single identity across a free-to-play desktop game, multiple mobile training apps, and a powerful, web-based simulation service. The backend's primary role is to authenticate users, authorize paid features, and manage a high-throughput queue of simulation jobs.

---

## 2. Core Architectural Principles

*   **Scientific Specificity via JSON:** The `.json` file is the immutable "atom" of a simulation. All inputs to the `jost_engine` will be in the form of a `.json` structure to guarantee reproducibility. All outputs will also be a `.json` structure.
*   **User Data Sovereignty:** The user is the custodian of their own data. All user-generated content (custom profiles, simulation histories) will be stored in a database on the user's local device. Our backend will only store user account information and temporary, in-flight job data.
*   **Centralized Control:** The Django API server is the central gatekeeper. It is responsible for Authentication (verifying user identity), Authorization (checking for a valid subscription), and Job Queuing (managing the simulation workload).
*   **Engine Purity:** The `jost_engine`'s core computational logic remains pure. It will be augmented with a data access layer that allows it to read its input from a database record, but its fallback to reading from local files will be preserved to ensure it remains a testable, standalone tool.

---

## 3. The "Simple Messenger" Architecture (Current Refactor)

Our top priority is to refactor the simulation workflow to be more robust and scalable, permanently fixing issues with the previous data contract. This new plan, "The Simple Messenger," simplifies the worker's role and creates a clear, database-centric data flow. This approach replaces the previous "Temporary File Bridge" mechanism.

### Workflow:

1.  **Job Creation & Persistence:** A user submits a simulation request through the Django frontend. The Django view immediately creates a `SimulationJob` record in the database. This record contains a unique `job_id` (UUID), the user's ID, a `status` field (e.g., "PENDING"), and the full JSON input for the simulation in a `request_data` field.
2.  **Task Queuing:** The view then places *only* the `job_id` into the Redis queue for Celery. This is a lightweight message that simply points to the persisted job.
3.  **Worker Task Execution:** A Celery worker, running as a separate process, picks up the `job_id` from the queue.
4.  **Database Bridge to Engine:** The Celery task's sole responsibility is to import and call a new function in the backend, `run_simulation_from_db(job_id)`, passing the ID it received.
5.  **Engine Data Access:** The `jost_engine`'s `run_simulation_from_db` function contains the logic to connect to the Django database, fetch the `SimulationJob` record using the `job_id`, and retrieve the simulation parameters from the `request_data` field.
6.  **Simulation & Results Storage:** The engine runs the simulation using the retrieved parameters. Upon completion, it saves the JSON results back to the `result_data` field of the same `SimulationJob` record and updates the `status` to "COMPLETE".
7.  **Result Display:** The user can then view the results on a dedicated page, which queries the `SimulationJob` model to fetch and display the `result_data`.

### Benefits:

*   **Decoupling:** This architecture decouples the long-running simulation from the web request, ensuring the user interface remains responsive.
*   **Reliability:** By persisting the complete job details in the database *before* queuing, we create a durable system. The message in the queue is disposable; the database record is the source of truth.
*   **Clean Contract:** It establishes a clean and robust data contract. The Django application is responsible for managing the database, and the `jost_engine` is responsible for computation, with a well-defined "database bridge" connecting them.

---

## 4. The "How": Detailed Phased Implementation Plan

This is a high-level roadmap for building the full ecosystem.

### **Phase 1: Solidify the Monolith (Current Work)**
- [ ] **1.1: Complete the "Database Bridge" Refactor:** (The plan is finalized and documented above).
- [ ] **1.2: Build a Robust Test Suite:**

### **Phase 2: Evolve the Monolith into an API**
- [ ] **2.1: Introduce Django REST Framework (DRF):**
- [ ] **2.2: Build Core API Endpoints:**
- [ ] **2.3: Implement API Authentication:**

### **Phase 3 & 4: Build Clients & Scale the Simulation Service**
- [ ] **3.1: Develop the Desktop Game Client:**
- [ ] **4.1: Upgrade the Message Broker:**
    - **Action:** Provision a managed RabbitMQ or Google Cloud Pub/Sub instance.
    - **Action:** Update the Celery configuration in the Django project and the Simulation Worker to use the new, more robust broker instead of Redis.
- [ ] **4.2: Containerize the Simulation Worker:**
- [ ] **4.3: Deploy to an Auto-scaling Platform:**

### **Phase 5: Commercialization and Analytics**
- [ ] **5.1: Integrate Payment Gateway:**
- [ ] **5.2: Implement Feature Gating:**
- [ ] **5.3: Build an Analytics Pipeline:**

---

## Appendix: Feature Backlog

*This section contains a backlog of detailed feature ideas and enhancements for future development.*

### 1. Backend Engine Enhancements (`jost_engine`)

*Objective: Increase the power, accuracy, and scope of the core simulation engine.*

- [ ] **Harden Backend Test Strategy:** Review existing tests and add coverage for edge cases and complex simulation scenarios to reach a target of 95% test coverage.
- [ ] **Enhance "Master" Profiles:**
    - [ ] Update master casino profiles to include rules for Insurance and both Early and Late Surrender.
    - [ ] Update master playing strategies to correctly utilize surrender and insurance options.
- [ ] **Implement True Count-Based Playing Strategies:** Add the capability for playing strategies (not just betting strategies) to alter their decisions (e.g., hit/stand) based on the true count.
- [ ] **Expand Rule Sets to Spanish 21:**
    - [ ] Implement all backend game logic and rule variations required for Spanish 21 simulations.
    - [ ] Update the database and frontend to support the configuration and execution of Spanish 21 simulations.

### 2. Advanced Simulation Features

*Objective: Provide more insightful results and allow for more complex strategy generation.*

- [ ] **Improve Results Analysis:** Enhance the simulation results page to include more advanced metrics, such as:
    - [ ] Dollars per hour estimate.
    - [ ] N0 (number of hands required to have a statistical advantage).
    - [ ] Risk of Ruin percentage.
- [ ] **Cross-Validation Testing:** Create a test suite that runs a standardized simulation scenario in our engine and compares the results against a known, published simulation result to validate the engine's accuracy.
- [ ] **Frontend-Driven Playing Strategy Generation:** Adapt the existing `strategy_generator.py` script so that users can generate new, optimal playing strategies directly from the web interface by selecting a set of casino rules. This will require a Celery task for asynchronous execution.

### 3. Advanced Betting Strategy Interface

*Objective: Move from simple, static betting strategies to a dynamic, user-configurable, and AI-drivable system.*

- [ ] **Phase 1: Backend Engine Enhancement for Rule-Based Strategies:**
    - [ ] **Data Model:** Design a new JSON schema for rule-based strategies that supports a prioritized list of rules with multiple conditions (e.g., `true_count_min`, `last_hand_result`).
    - [ ] **Engine Logic:** Modify `jost_engine` to parse and execute the new rule-based format, iterating through rules by priority.
    - [ ] **Testing:** Write new unit tests to validate the rule-based engine logic.

- [ ] **Phase 2: Dynamic Strategy Builder UI:**
    - [ ] **Database Models:** Extend the Django models to support named `BettingStrategy` objects composed of multiple `StrategyRule` entries.
    - [ ] **Forms & Views:** Create the Django views and forms needed for CRUD operations on these new models.
    - [ ] **Builder Template:** Develop a user interface, likely using JavaScript, to allow users to dynamically add, remove, and re-order the rules for a given strategy.

### 4. AI-Powered Strategy Generation

*Objective: Build upon the Dynamic Strategy Builder by adding a "Generative AI" feature that can discover optimal betting strategies based on high-level user goals.*

- [ ] **Phase 1: AI Core & Backend Integration:**
    - [ ] **Research & Scoping:** Choose an AI methodology (e.g., Genetic Algorithm) and define the "fitness function" to score a strategy's performance based on user goals (e.g., profit vs. risk).
    - [ ] **AI Orchestrator Service:** Create a new service that generates populations of strategies, runs simulations for each, scores them, and creates the next generation.
    - [ ] **Asynchronous Task:** Integrate the AI orchestrator into a long-running Celery task.

- [ ] **Phase 2: AI Generation Frontend UI:**
    - [ ] **"Generate Strategy" Page:** Create a new page where users define high-level objectives (e.g., sliders for "Aggressiveness vs. Safety").
    - [ ] **Task Initiation & Status:** The form will trigger the Celery task and redirect to a status page that shows the progress of the AI's generation process.
    - [ ] **Results:** The AI's best-discovered strategy will be automatically saved and presented to the user for analysis and refinement.
