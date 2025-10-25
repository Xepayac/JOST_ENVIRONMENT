### Project Status & Next Steps

**Current Situation:**

We have successfully completed a thorough architectural review of the Blackjack Simulation Platform. This process was initiated after diagnosing a critical bug where the frontend was sending an incorrect data payload to the backend simulation engine.

Specifically, we identified that the Flask web application was passing the *entire contents* of a strategy's JSON file to the Celery worker, when the backend `jost_engine` only expects a dictionary containing the strategy's *name* (e.g., `{'name': 'h17_basic_strategy'}`).

To clarify this and other system interactions, we have created a comprehensive `ARCHITECTURE.md` document. This document now fully details the roles of the frontend, the backend, the asynchronous communication protocol (Celery and Redis), and the data contracts between them.

**Moving Forward:**

With a clear and agreed-upon understanding of the architecture, our immediate goal is to implement the fix for the bug we diagnosed.

1.  **Implement the Fix:** We will modify the `run_simulation_action` route within `frontend/blackjack_simulator/app.py`.
2.  **Correct the Payload:** Inside this function, we will adjust the creation of the `simulation_config` dictionary to ensure the `strategy` key is formatted correctly before being passed to the Celery task.
3.  **Verify the Solution:** After applying the code change, we will run a new simulation from the web interface to confirm that the bug is resolved and that the simulation engine receives the correct data and executes successfully.