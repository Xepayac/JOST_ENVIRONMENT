# Contributing to JOST_Streamlit

Welcome! This document outlines the development process and guidelines for this project. Following these instructions will ensure a smooth and effective collaboration.

## Our Collaboration Model

We use a partnership model to build this software:

*   **The Architect (The User):** Defines the vision, sets the strategic goals, and makes key architectural decisions.
*   **The Builder (The AI):** Executes the plan, writes and refactors code, performs analysis, and manages the project's state.

Your primary goal as the Builder is to understand the Architect's intent and use your skills to bring that vision to life efficiently.

## Project Documentation

This project's detailed documentation is located in the `docs/` folder. It is the single source of truth for our plans and architecture.

*   **[Development Plan (`docs/PLAN.md`):](docs/PLAN.md)** This document contains the immediate, step-by-step plan for the current development work. It is our primary "work order."
*   **[Technical Architecture (`docs/ARCHITECTURE.md`):](docs/ARCHITECTURE.md)** This document is the definitive technical blueprint for the application.

## Git Workflow

This project follows a strict, professional Git workflow. All contributors must read and adhere to the process outlined in our **[Git Workflow Guide (`docs/GIT_WORKFLOW.md`)](docs/GIT_WORKFLOW.md)**.

## Development Workflow

Before taking any action, it is crucial to understand the project's current state and goals. The general workflow is as follows:

1.  **Understand the Goal:** Start by analyzing the Architect's request.
2.  **Propose a Plan:** If the task is complex or involves significant changes, outline your plan before you begin writing code.
3.  **Execute:** Implement the changes, following the project's standards.
4.  **Review:** Present the completed work to the Architect for review.

## Development Environment Setup

This project uses a Python virtual environment (`venv`) to manage dependencies.

1.  **Create the Virtual Environment:**
    If the `.venv` directory does not exist, create it:
    ```sh
    python -m venv .venv
    ```

2.  **Install Dependencies:**
    Install the required packages into the virtual environment.
    ```sh
    .venv/bin/pip install -r requirements.txt
    ```

3.  **Install the Backend Engine:**
    To make the backend available to the Streamlit app, install it in editable mode.
    ```sh
    .venv/bin/pip install -e backend
    ```

4.  **Run the application:**
    ```sh
    .venv/bin/streamlit run app.py
    ```

## Coding Standards

*   **Code Formatting:** All Python code should be formatted using the `black` code formatter.
*   **Clarity:** Write clear, maintainable code with meaningful variable names.
*   **Modularity:** Keep functions and modules focused on a single responsibility.
