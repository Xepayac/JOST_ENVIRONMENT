# JOST Web Service: API Reference Guide

## 1. Introduction

This document is the definitive technical contract for the JOST Web Service API. It provides a detailed, developer-focused guide for all available endpoints. The primary consumer of this API is the `user_terminal`.

All API endpoints are prefixed with `/api/`. All data is sent and received as `application/json`.

---

## 2. Authentication

All endpoints described in this guide require authentication.

*   **Mechanism:** The API uses Django's built-in session authentication for browser-based interaction (like our admin panel) and will be configured to use Token Authentication for programmatic access from the `user_terminal`.
*   **Error Response:** If a request is made without proper authentication, the server will respond with a `401 Unauthorized` status code.

---

## 3. The Profile API

This set of endpoints allows authenticated users to manage their personal library of custom profiles (casinos, players, betting strategies).

### 3.1. List & Create Profiles

*   **Endpoint:** `GET /api/profiles/`
*   **Method:** `GET`
*   **Description:** Retrieves a list of all profiles belonging to the currently authenticated user.
*   **Success Response (`200 OK`):**
    ```json
    [
        {
            "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
            "user": "testuser",
            "profile_type": "casino",
            "name": "My Custom H17 Casino",
            "data": { "dealer_stands_on_soft_17": false },
            "created_at": "2023-10-27T10:00:00Z",
            "updated_at": "2023-10-27T10:00:00Z"
        }
    ]
    ```

*   **Endpoint:** `POST /api/profiles/`
*   **Method:** `POST`
*   **Description:** Creates a new profile for the authenticated user.
*   **Request Body:**
    ```json
    {
        "profile_type": "player",
        "name": "Aggressive High-Roller",
        "data": {
            "bankroll": 50000,
            "playing_strategy": "perfect_s17_basic_strategy",
            "betting_strategy": "true_count_betting"
        }
    }
    ```
*   **Success Response (`201 Created`):** Returns the newly created profile object.
*   **Error Response (`400 Bad Request`):** Returned if the request body is missing required fields or contains invalid data.

---

### 3.2. Retrieve, Update, & Delete a Specific Profile

*   **Endpoint:** `GET /api/profiles/{id}/`
*   **Method:** `GET`
*   **Description:** Retrieves a single profile by its unique ID. The server will return a `404 Not Found` if the profile does not exist or does not belong to the user.
*   **Success Response (`200 OK`):** Returns the requested profile object.

*   **Endpoint:** `PUT /api/profiles/{id}/`
*   **Method:** `PUT`
*   **Description:** Updates an entire profile object. All fields are required.
*   **Request Body:** The full profile object with updated values.
*   **Success Response (`200 OK`):** Returns the updated profile object.

*   **Endpoint:** `PATCH /api/profiles/{id}/`
*   **Method:** `PATCH`
*   **Description:** Partially updates a profile object. Only the fields to be changed are required.
*   **Request Body:** An object containing only the fields to be updated.
*   **Success Response (`200 OK`):** Returns the updated profile object.

*   **Endpoint:** `DELETE /api/profiles/{id}/`
*   **Method:** `DELETE`
*   **Description:** Deletes a profile.
*   **Success Response (`204 No Content`):** An empty response indicating successful deletion.

---

## 4. The Simulation API

This set of endpoints allows users to submit simulation jobs and retrieve their results.

### 4.1. Submit a New Simulation Job

*   **Endpoint:** `POST /api/submit/`
*   **Method:** `POST`
*   **Description:** Submits a new simulation job to the asynchronous queue.
*   **Request Body:** The full simulation configuration JSON, identical to the format used by the `jost_engine`.
    ```json
    {
        "casino": "perfect_h17_casino",
        "num_rounds": 10000,
        "players": [
            {
                "profile": "perfect_player_rich",
                "playing_strategy": "perfect_h17_basic_strategy",
                "betting_strategy": "true_count_betting"
            }
        ]
    }
    ```
*   **Success Response (`202 Accepted`):** Indicates the job was successfully queued. The response body contains the `job_id` needed to check the status.
    ```json
    {
        "message": "Simulation job accepted.",
        "job_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef"
    }
    ```

### 4.2. Check Job Status

*   **Endpoint:** `GET /api/status/{job_id}/`
*   **Method:** `GET`
*   **Description:** Retrieves the current status of a simulation job.
*   **Success Response (`200 OK`):**
    ```json
    {
        "job_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
        "status": "COMPLETE" // Can be PENDING, RUNNING, or COMPLETE
    }
    ```
*   **Error Response (`404 Not Found`):** Returned if the `job_id` is invalid.

### 4.3. Retrieve Job Results

*   **Endpoint:** `GET /api/results/{job_id}/`
*   **Method:** `GET`
*   **Description:** Retrieves the final results of a completed simulation job.
*   **Success Response (`200 OK`):**
    *   If the job is still `PENDING` or `RUNNING`, the `results` field will be `null`.
    *   If the job is `COMPLETE`, the `results` field will contain the full JSON output from the `jost_engine`.
    ```json
    {
        "job_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
        "status": "COMPLETE",
        "results": {
            "total_rounds": 10000,
            "player_statistics": [ /* ... detailed results ... */ ]
        }
    }
    ```
*   **Error Response (`404 Not Found`):** Returned if the `job_id` is invalid.
