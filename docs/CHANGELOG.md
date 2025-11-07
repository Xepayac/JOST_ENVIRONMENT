# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- _Nothing yet._

---

## [0.3.0] - 2023-10-29

### Changed
- **Major Architectural Refactoring:**
    - The Web Service has been refactored to be a **stateless, transactional "computational cloud"** in alignment with a new "local-first" architecture. It no longer stores any user-specific profile data.
    - Updated `ARCHITECTURE.md` to reflect the new "local-first" model and the role of the service as a scalable job orchestrator.

### Added
- **Developer Workbench:**
    - Created a robust, developer-focused testing tool (`simulation_form.html`) for submitting raw, fully-hydrated JSON simulation jobs.
    - Implemented the backing JavaScript to power the workbench.
- **Defaults API:**
    - Created a new `/api/defaults/` endpoint that serves a collection of all default profiles for new clients like the `user_terminal`.

### Removed
- **Removed the `profiles` App:**
    - The entire `profiles` Django application has been removed from the project, as its premise of storing user profiles on the service was architecturally incorrect.
    - This includes the removal of the `/api/profiles/` endpoint, the `Profile` model, and all related code.

---

## [0.2.0] - 2023-10-28

### Added
- **Comprehensive Project Documentation:**
    - Created `ONBOARDING.md`, `API_REFERENCE.md`, `ENGINE_DEEP_DIVE.md`, and `WEB_SERVICE_DEEP_DIVE.md`.
- **Dependencies:**
    - Added `djangorestframework` to `requirements.txt`.

### Changed
- **Documentation Structure:**
    - Organized all project documentation into a dedicated `/docs` directory.

---

## [0.1.0] - 2023-10-27

### Added
- **Initial "Level 2" Foundation:**
    - Created the `start-services.sh` orchestration script.
- **Core Simulation API:**
    - Implemented the core `/api/submit`, `/api/status`, and `/api/results` endpoints.
- **Initial Project Documentation:**
    - Created `airules.md`, `JOST_BUSINESS_PLAN.md`, `ARCHITECTURE.md`, etc.
