# JOST Blackjack Simulation Platform: README

Welcome to the JOST project. This document is your starting point and primary action plan.

## 1. Our Guiding Principles (The "Pyramid of Knowledge")

Before you begin, you must understand our development process. All work is guided by the principles in these three documents:

1.  **`airules.md`:** Explains **how we work together**.
2.  **`ARCHITECTURE.md`:** Explains **how the system is designed**.
3.  **`DEVELOPMENT_ENVIRONMENT.md`:** Explains **how our workshop is set up**.

---

## 2. Current Status: "Level 2" Foundation Complete

**Status:** We have successfully completed our "Foundation First" pivot. Our development environment is now managed by a robust, stateful orchestration script (`start-services.sh`), and our Core API is fully functional and verified. This milestone is documented in our `CHANGELOG.md`.

**Next Phase:** We will now begin building the core features of the web service.

---

## 3. New High-Priority Goal: Custom Profile Management

**Directive:** Our next goal is to build the API endpoints that will allow a user of the `user_terminal` to create, read, update, and delete (CRUD) their own custom simulation profiles for casinos, players, and betting strategies.

This is the first major step in transforming our service from a demonstration tool into a powerful, user-centric platform.

---

## 4. Action Plan: The "Profile" API

We will begin by creating a new, dedicated Django app for profile management and defining its data model.

### [ ] 4.1. Create and Register the `profiles` App

- **Purpose:** To create a new, dedicated app to house all logic related to managing user-defined profiles.
- **Action 1:** Use the Django `startapp` command to create the new app.
- **Command 1:** `(cd service && source ../.venv/bin/activate && python manage.py startapp profiles)`
- **Verification 1:** The directory `service/profiles` will exist.
- **Action 2:** Add the new app to the `INSTALLED_APPS` list in the Django settings.
- **File:** `service/service/settings.py`
- **Modification 2:** Add `'profiles.apps.ProfilesConfig',` to the `INSTALLED_APPS` list.
- **Verification 2:** The development environment will start without errors using `./start-services.sh start`.

### [ ] 4.2. Define the `Profile` Data Model

- **Purpose:** To create the database model that will store all user-created profiles.
- **Action:** Update the `service/profiles/models.py` file with the new model definition.
- **Content:**
  ```python
  from django.db import models
  from django.contrib.auth.models import User
  import uuid

  class Profile(models.Model):
      PROFILE_TYPE_CHOICES = [
          ('casino', 'Casino'),
          ('player', 'Player'),
          ('betting', 'Betting Strategy'),
      ]

      id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
      user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='profiles')
      profile_type = models.CharField(max_length=10, choices=PROFILE_TYPE_CHOICES)
      name = models.CharField(max_length=100)
      data = models.JSONField()
      created_at = models.DateTimeField(auto_now_add=True)
      updated_at = models.DateTimeField(auto_now=True)

      class Meta:
          unique_together = ('user', 'profile_type', 'name')

      def __str__(self):
          return f"{self.user.username}'s {self.get_profile_type_display()} - {self.name}"
  ```
- **Verification:** The file will be updated.

### [ ] 4.3. Create and Apply Database Migrations

- **Purpose:** To apply the new `Profile` model to our database schema.
- **Action:** Run the `makemigrations` and `migrate` commands using our orchestration script.
- **Command:** `./start-services.sh migrate`
- **Verification:** The script will report that the migrations have been successfully created and applied.

---

## 5. Standard Operating Procedures (The "How-To" Guide)

- **To Start All Services:** `./start-services.sh start`
- **To Stop All Services:** `./start-services.sh stop`
- **To Restart All Services:** `./start-services.sh restart`
- **To Check Service Status:** `./start-services.sh status`
- **To View All Logs (Streaming):** `./start-services.sh logs`
- **To Run Migrations Manually:** `./start-services.sh migrate`
