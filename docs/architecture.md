# DeadlineAI Architecture Documentation

## Overview

DeadlineAI uses a **Clean Architecture** combined with a **Feature-based Modular Structure**. This setup ensures that each module (like auth, calendar, drive, etc.) is isolated, testable, and maintainable.

The workspace is organized into layers:
1. **Domain Layer**: Contains business rules, pure entity models, and abstract repository interfaces. It has zero external dependencies (pure Dart).
2. **Infrastructure (Data) Layer**: Contains database access (Drift/SQLite), network calls (Google API clients, Gemini Generative AI client), repository implementations, and data sources.
3. **Application Layer**: Contains business logic, providers (Riverpod), and AI agent tool orchestration.
4. **Presentation Layer**: Contains Flutter widgets, page layouts (One Dark theme), states, and user interactions.

---

## Directory Structure

```text
lib/
├── core/
│   ├── database/        # Drift database & migrations
│   ├── navigation/      # GoRouter configuration
│   ├── theme/           # One Dark theme constants and tokens
│   ├── services/        # Encryption & secure storage
│   └── utils/           # Shared helpers
├── features/
│   ├── auth/            # Google Sign-In & token management
│   ├── ai/              # AI Chat & Gemini Agent Tool-calling
│   ├── calendar/        # Google Calendar sync and creation
│   ├── drive/           # Google Drive index & quick search
│   ├── classroom/       # Google Classroom assignments
│   ├── email/           # Email dashboard & AI summaries
│   ├── meet/            # Google Meet meeting creator
│   ├── insights/        # Daily dashboard briefing & risk analysis
│   └── settings/        # Preferences & local configs
└── main.dart            # Application entry point
```

Within each feature module, we follow the Clean Architecture layer structure:
```text
features/feature_name/
├── domain/
│   ├── entities/        # Pure Dart models
│   └── repositories/    # Abstract interfaces
├── infrastructure/
│   ├── datasources/     # Remote (Google API) and Local (Drift) data sources
│   └── repositories/    # Concrete implementations of repositories
├── application/
│   └── providers/       # Riverpod providers, Notifier classes
└── presentation/
    ├── pages/           # Screen widgets
    └── widgets/         # Component widgets
```

---

## Database Schema (SQLite via Drift)

We use Drift (SQLite) to securely cache offline metadata, store local preferences, and record AI conversations.

### 1. `chats`
Stores AI Chat messages.
* `id` (Text, Primary Key)
* `role` (Text, e.g., 'user', 'model')
* `content` (Text)
* `timestamp` (DateTime)

### 2. `ai_memories`
Stores extracted insights and memories about the user (e.g., "User is taking Machine Learning and Linear Algebra").
* `key` (Text, Primary Key)
* `value` (Text)
* `updated_at` (DateTime)

### 3. `cached_deadlines`
Caches Google Classroom assignments for instant offline dashboard loads.
* `id` (Text, Primary Key)
* `course_name` (Text)
* `title` (Text)
* `description` (Text, Nullable)
* `due_time` (DateTime, Nullable)
* `alternate_link` (Text)
* `is_submitted` (Boolean)

### 5. `cached_emails`
Caches latest Gmail messages for local display and summary generation.
* `id` (Text, Primary Key)
* `sender` (Text)
* `subject` (Text)
* `snippet` (Text)
* `body_summary` (Text, Nullable)
* `received_at` (DateTime)
* `is_academic` (Boolean)

---

## Core Technologies

* **Framework**: Flutter Desktop (Linux, Windows, macOS)
* **Language**: Dart
* **State Management**: Riverpod
* **Routing**: GoRouter
* **Local Database**: Drift + SQLite
* **Secured Storage**: Flutter Secure Storage (AES-encrypted OAuth credentials)
* **AI engine**: Google Gemini API via `package:google_generative_ai`
