# Developer Onboarding Guide

## 1. Welcome to the JOST Project

This guide provides the exact, step-by-step instructions to get the JOST Blackjack Simulation Platform running on your local development machine. Follow these steps to go from a fresh `git clone` to a fully operational environment in minutes.

**Our Goal:** To provide a "golden path" for setup, eliminating environmental friction and allowing you to focus on development.

---

## 2. Prerequisites

*   You must be working within the **Firebase IDX environment**.
*   **Nix** must be installed and configured in your workspace (this is the default in IDX).
*   You have `git` installed and have cloned the project repository.

---

## 3. Step-by-Step Setup Instructions

### Step 3.1: Activate the Python Virtual Environment

All our Python tooling is managed within a local virtual environment (`.venv`). You must activate it first. This command should be run from the project's root directory.

```bash
source .venv/bin/activate
```
**Verification:** Your terminal prompt will now be prefixed with `(.venv)`.

### Step 3.2: Start All Services

Our entire development stack (Web Server, Celery Worker, Redis) is managed by a single orchestration script.

```bash
./start-services.sh start
```
**Verification:** The script will output status messages indicating that `gunicorn`, `celery`, and `redis-server` have been started successfully. You can confirm their status at any time with `./start-services.sh status`.

### Step 3.3: Apply Database Migrations

Ensure your local database schema is up-to-date with the latest data models.

```bash
./start-services.sh migrate
```
**Verification:** The script will report that all migrations have been successfully applied.

### Step 3.4: Create a Superuser Account

To interact with the API, you need a user account. We will create a superuser for this purpose.

```bash
(cd service && python manage.py createsuperuser)
```
Follow the prompts. For the smoke test, let's use the following credentials for simplicity:
*   **Username:** `testuser`
*   **Password:** `testpassword`

**Verification:** The command will complete with a "Superuser created successfully." message.

---

## 4. Smoke Test: Verifying Your Installation via API

Now, we will confirm that every component of the system is working correctly by submitting a test job directly to the API using `curl`. This is the primary way our `user_terminal` will interact with the service.

*(Note: In a real client, we would handle login and cookie management. For this manual test, we will log in via the browser once to get a session cookie.)*

### Step 4.1: Get a Session Cookie

1.  Open the web preview for the running application in your browser.
2.  Navigate to the `/admin` URL.
3.  Log in using the `testuser` / `testpassword` credentials you just created.
4.  Open your browser's developer tools, go to the "Storage" or "Application" tab, find the Cookies for the site, and copy the value of the `sessionid` cookie.

### Step 4.2: Submit a Simulation Job via `curl`

Now, from your terminal, we will submit a job. Replace `YOUR_SESSION_ID_HERE` with the value you just copied.

```bash
# Define the session cookie and the sample job data
SESSION_ID="YOUR_SESSION_ID_HERE"
JOB_DATA='{
    "casino": "perfect_h17_casino",
    "num_rounds": 100,
    "players": [
        {
            "profile": "perfect_player_rich",
            "playing_strategy": "perfect_h17_basic_strategy",
            "betting_strategy": "true_count_betting"
        }
    ]
}'

# Submit the job and extract the job_id from the response
JOB_ID=$(curl -s -X POST http://127.0.0.1:8000/api/submit/ \
-H "Content-Type: application/json" \
-H "Cookie: sessionid=$SESSION_ID" \
-d "$JOB_DATA" | grep -o '"job_id": "[^"]*' | cut -d '"' -f 4)

echo "Job submitted with ID: $JOB_ID"
```
**Verification:** The command will print a message like `Job submitted with ID: <a-uuid-string>`.

### Step 4.3: Check Job Status and Get Results

Wait a few seconds for the simulation to run, then use the `JOB_ID` to check the status.

```bash
# Check the job status
curl -s -H "Cookie: sessionid=$SESSION_ID" http://127.0.0.1:8000/api/status/$JOB_ID/

# Once the status is "COMPLETE", get the full results
curl -s -H "Cookie: sessionid=$SESSION_ID" http://127.0.0.1:8000/api/results/$JOB_ID/ | python -m json.tool
```
**Verification:** The first command will show the job's status. Once it shows `"status": "COMPLETE"`, the second command will print the full, formatted JSON results of the simulation. If you see this output, your environment is **fully operational and verified**.

---

## 5. Next Steps

You are now ready for development.

*   To **view live logs** from all services: `./start-services.sh logs`
*   To **stop all services** when you are finished: `./start-services.sh stop`

Welcome to the team.
