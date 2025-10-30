# Plan to Standardize Frontend/Backend Conventions

**Goal:** Establish a single source of truth for shared terminology, rules, and codes used by both the `jost_engine` backend and the web frontend. This will eliminate "magic strings" (e.g., `'u'` for Surrender), prevent inconsistencies, and make the entire codebase more maintainable.

---

### Step 1: Create a Central Convention File

This file will act as the single source of truth for all shared terminology.

-   **Action:** Create a new file named `conventions.py` inside the backend's source directory: `backend/src/jost_engine/conventions.py`.
-   **Rationale:** Placing it in the backend engine's source code establishes the engine as the authority on game logic and terminology. The frontend will import from this file.

### Step 2: Define Player Action Conventions

Populate the new file with constants for player actions to provide a clear, readable reference instead of cryptic single-letter codes.

-   **Action:** Add the following code to `backend/src/jost_engine/conventions.py`:
    ```python
    # Player Action Codes
    # These are the short codes used internally by the engine and in strategy files.
    ACTION_HIT = 'h'
    ACTION_STAND = 's'
    ACTION_DOUBLE = 'd'
    ACTION_SPLIT = 'p'
    ACTION_SURRENDER = 'u'

    # Mapping from action codes to their human-readable names for UIs and reports.
    ACTION_NAMES = {
        ACTION_HIT: 'Hit',
        ACTION_STAND: 'Stand',
        ACTION_DOUBLE: 'Double Down',
        ACTION_SPLIT: 'Split',
        ACTION_SURRENDER: 'Surrender',
    }
    ```

### Step 3: Refactor the Backend to Use the New Conventions

Update the `jost_engine` to import and use the constants from `conventions.py` instead of hardcoded strings.

-   **Action:**
    1.  Search for all files in the `backend/src/jost_engine/` directory that use action codes (e.g., `'h'`, `'s'`, `'u'`). Key files will likely include `rules/available_actions.py`, `playing_strategy.py`, and any tests that simulate player decisions.
    2.  Import the new constants at the top of each relevant file: `from . import conventions`.
    3.  Replace all hardcoded strings with the constants. For example, change `if action == 'u':` to `if action == conventions.ACTION_SURRENDER:`.
-   **Rationale:** This makes the code self-documenting and ensures that if a code needs to change, it only has to be updated in `conventions.py`.

### Step 4: Formalize Casino Rule Naming Conventions

While the rule names are mostly consistent, formalizing them in the central file prevents future divergence and typos.

-   **Action:**
    1.  Analyze the forms in `frontend/blackjack_simulator/templates/` (like `create_casino.html`) and the `Ruleset` class in the backend to get a definitive list of all rule names.
    2.  Add a list of these names to `backend/src/jost_engine/conventions.py`:
        ```python
        # Casino Rule Attributes
        # These strings must match the attributes in the backend Ruleset class
        # and the field names in the frontend Casino forms.
        RULE_ATTRIBUTES = [
            'dealer_hits_on_soft_17',
            'allow_late_surrender',
            'allow_early_surrender',
            'allow_resplit_to_hands',
            'allow_double_after_split',
            'allow_double_on_any_two',
            'blackjack_payout',
            'num_decks',
            # ... and so on for all other rules.
        ]
        ```

### Step 5: Update the Frontend to Use the Conventions

Modify the frontend application to import and use these conventions, particularly in forms and templates, to ensure consistency with the backend.

-   **Action:**
    1. In `frontend/blackjack_simulator/routes.py`, when handling form submissions for creating a casino, explicitly use `RULE_ATTRIBUTES` from the conventions file to build the rules dictionary that is passed to the backend. This acts as a validation step.
    2. For any UI elements that display or select player actions (like in the future Dynamic Strategy Builder), use the `ACTION_NAMES` dictionary to populate the choices.
-   **Rationale:** This creates a robust link between the two parts of the application, reducing the chance of errors caused by typos or outdated terminology.
