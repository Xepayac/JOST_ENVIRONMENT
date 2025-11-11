# Plan for "JOST_Streamlit" MVP

This document outlines the development plan for creating the Minimum Viable Product (MVP) of the JOST_Streamlit application.

## Phase 1: Environment and Foundation

1.  **[ ] Create `app.py`:** Create the main application file. It will initially contain only the title.
2.  **[ ] Create `requirements.txt`:** Create a new `requirements.txt` file with the single entry: `streamlit`. We will add more dependencies as needed.
3.  **[ ] Update `CONTRIBUTING.md`:** Solidify the setup instructions in the `Development Environment Setup` section to be the definitive guide:
    *   `pip install -r requirements.txt`
    *   `pip install -e backend`
    *   `streamlit run app.py`

## Phase 2: Building the User Interface in `app.py`

1.  **[ ] File Discovery Logic:**
    *   Create a helper function that can scan the subdirectories within `backend/src/jost_engine/data/` (e.g., `casinos`, `players`, `playing_strategies`, `betting_strategies`).
    *   This function will return lists of the available profile filenames.

2.  **[ ] UI Widget Implementation:**
    *   Add a header: "Simulation Configuration".
    *   Use `st.selectbox` to create four dropdown menus, one for each strategy/profile type. The options in these dropdowns will be populated by the file discovery function.
    *   Use `st.number_input` to create the input for "Number of Rounds," with a default value of `10`.
    *   Use `st.button` to create a button with the label "Run Simulation".

## Phase 3: Engine Integration in `app.py`

1.  **[ ] Import the Engine:** Add `from backend.src.jost_engine.main import run_simulation_from_config` to the top of `app.py`.
2.  **[ ] Wire the "Run" Button:**
    *   When the button is clicked, the application will read the selected filenames from the four dropdowns and the number of rounds from the number input.
    *   It will then construct the `config` dictionary exactly as required by the `jost_engine`.
    *   It will call the `run_simulation_from_config()` function, passing the `config` object to it.
    *   The entire call will be wrapped in a `try...except` block to gracefully handle and display any errors from the engine.
3.  **[ ] Display the Output:**
    *   The JSON data returned by the engine will be captured.
    *   A new header, "Simulation Results," will be displayed.
    *   The raw JSON output will be printed to the screen using `st.json()`. This ensures we see the complete, unfiltered output for debugging and verification.
