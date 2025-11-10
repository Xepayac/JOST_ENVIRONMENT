# 👑 JOST Blackjack Ecosystem Project 👑

**ARCHIVED PROJECT: This repository is now read-only. The project has been shelved in favor of a new, simplified approach using Streamlit.**

This repository contains the final state of the JOST Blackjack Ecosystem, a project originally designed as a multi-tiered simulation engine. The development focus has since shifted to a new, standalone Streamlit application that will be hosted in a separate repository.

This README has been updated to serve as a historical document, outlining the original vision and providing instructions for running the project in its final, archived state.

---

## Original Project Vision

The project was initially designed as a sophisticated, three-tiered architecture composed of independent components managed via Git submodules:

1.  **`JOST_ENGINE_7` (The Backend):** A pure, headless Python library responsible for running high-volume Blackjack simulations.
2.  **`JOST_WEB_SERVICE` (The Service Layer):** A scalable job orchestrator (using Django, Celery, and Redis) designed to accept simulation requests, run them as background jobs, and manage results.
3.  **`user_terminal` (The User Interface):** A terminal-based application intended for users to create and manage their custom JSON-based playing and betting strategies.

This modular design was intended to separate the core simulation logic from the web-serving and user-interaction layers, allowing for independent development and scalability.

## Running the Final Archived Version

The following instructions detail how to set up and run the environment in its final "Level 4" declarative, IDX-native state.

### 1. Install Dependencies

Install the required Python packages for the entire ecosystem:

```bash
pip install -r requirements.txt
```

### 2. Install the Backend Engine

Install the `jost_engine` in editable mode to make it available as a library:

```bash
cd backend && pip install -e . && cd ..
```

### 3. Verify the Setup

Run the test suite to ensure all backend components are functioning correctly:

```bash
pytest
```

---

## License and Restrictions on Use

**License Grant:** You, the User, are hereby granted a non-exclusive, royalty-free, worldwide license to use, execute, and modify the Software for the purpose of providing direct, interactive coding assistance to the User within the Project IDX development environment, subject to the restrictions and conditions set forth in this Agreement.

**Restrictions on Use:**
1.  The Software may only be used as part of the integrated development environment and may not be extracted, distributed, or used as a standalone product.
2.  The license granted herein is contingent upon the User's use of Google Gemini as their primary AI-assisted coding tool. The use of any other AI-assisted coding tool (e.g., GitHub Copilot, Amazon CodeWhisperer) in conjunction with or as a replacement for Google Gemini is a violation of this license.
3.  The Software is provided "as is" and without warranty of any kind. Google shall have no liability for any damages arising out of or in connection with the use of the Software.
