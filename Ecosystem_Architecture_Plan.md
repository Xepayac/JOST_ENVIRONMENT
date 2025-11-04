# Architectural Plan: The JOST Blackjack Product Ecosystem (Federated Model)

## 1. Executive Summary & Vision

This document outlines the definitive architectural plan for the JOST Blackjack product ecosystem. This architecture is designed to support a suite of interconnected applications, ensure scientific integrity, protect user data sovereignty, and provide a scalable, commercial-grade backend.

**The Vision:** To create a unified platform where a user has a single identity across a free-to-play desktop game, multiple mobile training apps, and a powerful, web-based simulation service. User-generated content, such as custom strategies, will be stored on the user's local device but can be seamlessly used by our backend simulation engine. The backend's primary role is to authenticate users, authorize paid features, and manage a high-throughput queue of simulation jobs.

---

## 2. Core Architectural Principles

*   **Scientific Specificity via JSON:** The `.json` file is the immutable "atom" of a simulation. All inputs to the `jost_engine` will be in the form of a `.json` structure to guarantee reproducibility. All outputs will also be a `.json` structure.
*   **User Data Sovereignty:** The user is the custodian of their own data. All user-generated content (custom profiles, simulation histories) will be stored in a database on the user's local device. Our backend will only store user account information and temporary, in-flight job data.
*   **Centralized Control:** The Django API server is the central gatekeeper. It is responsible for Authentication (verifying user identity), Authorization (checking for a valid subscription), and Job Queuing (managing the simulation workload).
*   **Engine Purity:** The `jost_engine`'s core computational logic remains pure. It will be augmented with a data access layer that allows it to read its input from a database record, but its fallback to reading from local files will be preserved to ensure it remains a testable, standalone tool.

---

## 3. The Role of the Celery Worker & Message Broker

The Celery worker is the critical piece of "plumbing" that connects our fast, user-facing API to the slow, powerful `jost_engine`. Its role evolves as the platform scales.

### **Phase 1 (Current): The "Trusted Messenger"**

In the current monolithic architecture, the Celery worker's job is to be a simple and reliable messenger.

*   **Technology:** We use **Redis** as our message broker. It is lightweight, fast, and perfect for a single-server development setup, as configured in `start-background.sh`.
*   **Workflow:**
    1.  The Django view receives a request and places a `job_id` into the Redis queue.
    2.  The Celery worker, running as a separate process, picks up this `job_id`.
    3.  Because it is a trusted, internal component, the worker has the credentials to access our database. It uses the `job_id` to fetch the full simulation parameters.
    4.  It then delegates the job to the `jost_engine`.
*   **Benefit:** This decouples the long-running simulation from the web request, ensuring the user interface remains responsive.

### **Phase 4 (Scaling): The "Engine Room Foreman"**

When we scale to a multi-server "Simulation Service," the worker's role remains simple, but the underlying technology becomes more robust.

*   **Technology:** We will upgrade our message broker from Redis to an enterprise-grade solution like **RabbitMQ** or **Google Cloud Pub/Sub**.
*   **Why Upgrade?**
    *   **Durability:** RabbitMQ guarantees that if a user pays for a simulation, their job request will *never* be lost, even if the server crashes.
    *   **Reliability:** It requires workers to send an "acknowledgment" (ACK) after a job is successfully completed. If a worker crashes mid-simulation, the job is automatically put back on the queue for another worker to pick up.
    *   **Advanced Routing:** We can create priority queues (e.g., for paying users) or route different job types to specialized workers.
    *   **Visibility:** RabbitMQ provides a detailed management interface to monitor the health and throughput of our simulation service.
*   **Workflow:** The worker's core logic remains the same: it pulls a `job_id` from the queue and delegates the task. However, the guarantees provided by the new broker make the entire system vastly more reliable and scalable.

---

## 4. The "Round Trip" Data Flow: The Definitive Workflow
(This section remains the same, detailing the job creation, submission, and retrieval process)

---

## 5. The "How": Detailed Phased Implementation Plan

This is a high-level roadmap for building the full ecosystem.

### **Phase 1: Solidify the Monolith (Current Work)**
- [X] **1.1: Complete the "Database Bridge" Refactor:** (The plan is finalized)
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

*This section contains a backlog of detailed feature ideas and enhancements for future development, migrated from the old `.idx/todo.md` file.*

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
