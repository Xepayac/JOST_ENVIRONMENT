# JOST Ecosystem Architecture: A Blueprint for the Professional Player

## 1. The Mission: Statistical Certainty in a Game of Chance

The JOST project is a professional-grade toolkit designed to empower serious blackjack players with a decisive statistical advantage. This document outlines our **technical design**, our **strategic roadmap**, and serves as the central **hub for all project documentation**.

---

## 2. Core Principle: A "Local-First," Scalable Ecosystem

The entire ecosystem is built on a "local-first" principle. The `user_terminal` is the primary application where the user manages all their data. The Web Service acts as a powerful, stateless, and **horizontally scalable** computational utility.

---

## 3. Phased Implementation Roadmap

### **Phase 1: The Backend Foundation (Current Focus)**

*   **Goal:** To build and stabilize the core components of the simulation and service infrastructure.
*   **Key Milestones:**
    *   **[X]** Develop the `jost_engine` as a pure, standalone simulation library.
    *   **[X]** Implement a stateful, script-based development environment.
    *   **[X]** Implement the core API for submitting simulation jobs.
    *   **[ ]** **Refactor the Web Service** to be a stateless, transactional compute engine.
    *   **[ ]** Implement an API endpoint to serve default profiles to new clients.
    *   **[ ]** Build a Developer Workbench for internal testing.

### **Phase 2: The Player's Command Center**

*   **Goal:** To build the `user_terminal`, the flagship desktop application.

---

## 4. Component Architecture

### 4.1. The `user_terminal` (The Player's Home Base & Source of Truth)

This is the primary application where the user creates, saves, and manages all their custom JSON profiles locally. The terminal is responsible for constructing a complete, "hydrated" JSON object for a simulation and sending it to the Web Service.

### 4.2. The Web Service (The Scalable Job Orchestrator)

This is a powerful, temporary, and transactional utility.
*   **Stateless by Design:** It does **not** store any user-specific profiles. Its role is purely computational.
*   **Job Orchestrator:** Its primary function is to accept a fully-formed JSON simulation config from the `user_terminal` and place it onto a Celery queue. It is the front door for a potentially massive number of simultaneous jobs.
*   **Horizontally Scalable:** The Celery/Redis queue allows us to run a large, scalable pool of background workers. If we have 10,000 jobs to run, we can scale up the number of workers to meet the demand. Each worker is an independent process that consumes jobs from the queue and executes them using the `jost_engine`.
*   **Defaults Repository:** Its secondary function is to expose an API endpoint (`/api/defaults/`) that serves the collection of standard, default profiles to a `user_terminal` on its first startup.

### 4.3. The `jost_engine` (The Pure Scientific Core)

This is the heart of the system. It is a pure Python library that simply accepts a complete configuration object, runs a high-fidelity simulation, and returns the results. It is executed by the Celery workers.

---

## 5. Documentation Hub

*   **Business Vision:** `JOST_BUSINESS_PLAN.md`
*   **Onboarding:** `ONBOARDING.md`
*   **API Contract:** `API_REFERENCE.md`
*   **And more in the `/docs` directory...**
