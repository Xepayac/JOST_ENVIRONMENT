# Professional Git Workflow

This document outlines the standard Git workflow for the JOST_Streamlit project. A secondary purpose of this project is to learn and master this professional process. Adherence to this workflow is critical for maintaining a clean, understandable, and robust project history.

## The Workflow Cycle

All development work follows this six-step cycle. We never commit directly to the `main` branch.

### Step 1: Create an Issue

*   **Purpose:** To create a clear, documented task. Every new feature, bug fix, or documentation update begins here.
*   **Action:** Go to the project's GitHub page and create a new issue. The issue should have a descriptive title and a clear description of the work to be done.

### Step 2: Create a Feature Branch

*   **Purpose:** To create an isolated environment for your work. All changes will be made on this branch, leaving the `main` branch clean and stable.
*   **Action:** From the `main` branch, create and switch to a new branch. The branch name should be descriptive, often including the issue number.
    ```sh
    # Make sure you are on the main branch and have the latest changes
    git checkout main
    git pull

    # Create and switch to your new branch
    git checkout -b feature/issue-5-create-login-page
    ```

### Step 3: Do the Work

*   **Purpose:** To implement the changes described in the issue.
*   **Action:** Write code, create files, and make all necessary changes on your feature branch.

### Step 4: Commit the Work

*   **Purpose:** To save your progress in logical, well-documented steps.
*   **Action:** Stage and commit your changes. The commit message should be clear and concise, referencing the issue if possible.
    ```sh
    # Stage all changes
    git add .

    # Commit the changes
    git commit -m "feat: Implement login page layout (closes #5)"
    ```

### Step 5: Open a Pull Request (PR)

*   **Purpose:** To propose that your changes be merged into the `main` branch and to initiate a code review.
*   **Action:** Push your feature branch to the remote repository and then open a pull request on GitHub.
    ```sh
    git push -u origin feature/issue-5-create-login-page
    ```

### Step 6: Merge to `main`

*   **Purpose:** To officially incorporate your feature into the project's main codebase.
*   **Action:** After the pull request has been reviewed and approved, merge it into the `main` branch using the GitHub interface. This updates the official project history. The feature branch can then be deleted.
