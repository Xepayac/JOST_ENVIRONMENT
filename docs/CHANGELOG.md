# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- _Nothing yet._

---

## [0.4.0] - 2023-11-07

### Changed
- **Major Environment Refactoring (Level 4):** The entire development environment has been refactored to be **fully declarative and IDX-native**, eliminating the need for `foreman` and the `Procfile`. This provides a true "one-click" startup and permanently resolves the context and dependency issues that caused previous startup failures.
- **Updated `DEVELOPMENT_ENVIRONMENT.md`** to provide a highly detailed breakdown of the new, definitive "Level 4" architecture.
- **Simplified `start-services.sh`** to be a lightweight wrapper for one-off tasks like running migrations.

### Fixed
- **Fixed Critical `ModuleNotFoundError` Bugs:**
    - **Circular Import:** Resolved a critical bug caused by a filename collision between our `celery.py` configuration file and the `celery` library. The file was renamed to `celery_app.py`, and references were updated.
    - **Execution Context:** Corrected the `DJANGO_SETTINGS_MODULE` path in all application entry points (`manage.py`, `wsgi.py`, `celery_app.py`) to align with our flattened project structure. This permanently solved the "Two-Root Problem".
- **Fixed Django Static File Handling:** Removed incorrect `STATIC_ROOT` and `urls.py` configurations, allowing Django's development server to correctly serve the `workbench.js` file.

### Removed
- **Removed `Procfile`:** This file is no longer necessary, as all service definitions have been moved into the `.idx/dev.nix` file, which is the single source of truth for our environment.

---

## [0.3.0] - 2023-10-29

### Changed
- **Major Architectural Refactoring (Stateless Service):**
    - The Web Service was refactored to be a stateless "computational cloud".
    - Updated `ARCHITECTURE.md` to reflect the "local-first" model.

### Added
- **Developer Workbench:** Created the initial version of the developer testing tool.
- **Defaults API:** Created the `/api/defaults/` endpoint.

### Removed
- **Removed the `profiles` App:** The entire `profiles` Django application was removed.

---

## [0.2.0] - 2023-10-28

### Added
- **Comprehensive Project Documentation:** Created `ONBOARDING.md`, `API_REFERENCE.md`, etc.
- **Dependencies:** Added `djangorestframework` to `requirements.txt`.

### Changed
- **Documentation Structure:** Organized all documentation into a dedicated `/docs` directory.

---

## [0.1.0] - 2023-10-27

### Added
- **Initial "Level 2" Foundation:** Created the `start-services.sh` orchestration script.
- **Core Simulation API:** Implemented the core `/api/submit`, `/api/status`, and `/api/results` endpoints.
- **Initial Project Documentation.**
