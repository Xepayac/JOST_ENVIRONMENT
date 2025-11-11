# Plan for "JOST_Streamlit" MVP

This document outlines the development plan for creating the Minimum Viable Product (MVP) of the JOST_Streamlit application.

## Phase 1: Environment and Foundation

1.  **[X] Create `app.py`:** Create the main application file. It will initially contain only the title.
2.  **[X] Create `requirements.txt`:** Create a new `requirements.txt` file with the single entry: `streamlit`. We will add more dependencies as needed.
3.  **[X] Update `CONTRIBUTING.md`:** Solidify the setup instructions in the `Development Environment Setup` section to be the definitive guide.

## Phase 2: Building the User Interface in `app.py`

1.  **[X] File Discovery Logic:**
    *   Create a helper function that can scan the subdirectories within `data/defaults/` (e.g., `casinos`, `players`, `playing_strategies`, `betting_strategies`).
    *   This function will return lists of the available profile filenames.

2.  **[X] UI Widget Implementation:**
    *   Add a header: "Simulation Configuration".
    *   Use `st.selectbox` to create four dropdown menus, one for each strategy/profile type. The options in these dropdowns will be populated by the file discovery function.
    *   Use `st.number_input` to create the input for "Number of Rounds," with a default value of `10`.
    *   Use `st.button` to create a button with the label "Run Simulation".

## Phase 3: Engine Integration in `app.py`

1.  **[X] Import the Engine:** Add `from backend.src.jost_engine.main import run_simulation_from_config` to the top of `app.py`.
2.  **[X] Wire the "Run" Button:**
    *   When the button is clicked, the application will read the selected filenames from the four dropdowns and the number of rounds from the number input.
    *   It will then construct the `config` dictionary exactly as required by the `jost_engine`.
    *   It will call the `run_simulation_from_config()` function, passing the `config` object to it.
    *   The entire call will be wrapped in a `try...except` block to gracefully handle and display any errors from the engine.
3.  **[X] Display the Output:**
    *   The JSON data returned by the engine will be captured.
    *   A new header, "Simulation Results," will be displayed.
    *   The raw JSON output will be printed to the screen using `st.json()`. This ensures we see the complete, unfiltered output for debugging and verification.

---

# Plan for Issue #5: Feature: Custom Profile Management, Simulation Naming, and Persistent Result Storage (File-System)

**Link to Issue:** [https://github.com/Xepayac/JOST_ENVIRONMENT/issues/5](https://github.com/Xepayac/JOST_ENVIRONMENT/issues/5)

This task aims to enhance the `JOST_Streamlit` application by giving users full control over creating and managing custom simulation profiles (Casino, Player, Strategies), naming and reusing simulation configurations, and persistently saving detailed simulation results. All storage will initially be **file-system based**, without requiring a database.

## 1. Key Features to Implement:

*   **1.1. Simulation Naming & Configuration Saving:**
    *   **[X]** Add a new `st.text_input` field at the top of the "Simulation Configuration" section for "Simulation Name." This name will be used to organize custom profiles and saved results.
    *   **[X]** Implement a "Save Current Configuration" button that, when clicked, saves the currently selected parameters (Casino, Player, Strategies, Number of Rounds) into a JSON file, named after the user-provided "Simulation Name." These configuration files should be stored in a new, dedicated `configurations/` subdirectory within the `data/custom/` path (e.g., `backend/src/jost_engine/data/custom/configurations/`).

*   **1.2. Custom Profile Creation/Editing (GUI-based):**
    *   **[X]** Introduce separate sections or tabs in the Streamlit UI (e.g., "Manage Casinos," "Manage Players," "Manage Strategies").
    *   **[X]** Within each section, allow users to:
        *   **[X]** Load an existing default profile (e.g., `master_casino`) into an editable text area (`st.text_area`) or a set of input widgets.
        *   **[X]** Edit the JSON structure/values of the loaded profile directly in the GUI.
        *   **[X]** Provide a "Save Custom [Profile Type]" button.
        *   **[X]** Save the modified profile as a new JSON file into the appropriate `backend/src/jost_engine/data/custom/[profile_type]/` directory. The filename should be unique and ideally derived from a user-provided custom name.

*   **1.3. Reuse Custom Profiles in Simulation:**
    *   **[X]** Update the `st.selectbox` widgets for Casino, Player, Playing Strategy, and Betting Strategy to **include options from both `data/defaults/` and `data/custom/`** directories. Custom profiles should be clearly distinguishable (e.g., by prefixing their names with `[Custom]`).

*   **1.4. Reuse Past Simulation Configurations:**
    *   **[X]** Add a dropdown (`st.selectbox`) to "Load Previous Simulation Configuration." This dropdown should list the names of previously saved configurations (from Feature 1.1).
    *   **[X]** When a user selects a previous configuration, all relevant UI widgets (Casino, Player, Strategies, Number of Rounds) should be automatically populated with that configuration's data.

*   **1.5. Persistent Simulation Result Saving:**
    *   **[X]** After a simulation completes, the raw JSON output should be automatically saved to a new, dedicated `results/` folder (e.g., `backend/src/jost_engine/results/`).
    *   **[X]** The result file should be named using the "Simulation Name" (from Feature 1.1) and a timestamp to ensure uniqueness (e.g., `MySimName_20231027_143000.json`).

*   **1.6. Verification and Testing:**
    *   **[ ]** Conduct thorough local testing and manual verification to ensure all new features (custom profile management, simulation naming, configuration saving, result saving, and loading past configurations) are robust and functional.

## 2. Technical Considerations:

*   **File System Operations:** This task will heavily involve `os` module operations for listing, reading, and writing JSON files.
*   **JSON Serialization/Deserialization:** Proper handling of JSON data, including validation where appropriate, will be critical.
*   **Streamlit State Management:** `st.session_state` will be essential for managing the loaded custom profile data across reruns and for passing information between different UI sections.
