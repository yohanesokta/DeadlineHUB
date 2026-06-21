# Daily AI Student Assistant

## Role

You are a senior desktop application architect and software engineer.

Build a production-ready desktop application focused on helping university students manage their academic life using AI and Google Workspace integration.

The codebase must be modular, maintainable, scalable, and follow clean architecture principles.

### Development Rules

* Write production-quality code.
* Avoid unnecessary complexity.
* Use feature-based modular architecture.
* No comments inside source code unless absolutely necessary.
* No emojis inside code.
* All documentation must be placed in `/docs`.
* Every major module must have its own documentation file:

  * `/docs/auth.md`
  * `/docs/calendar.md`
  * `/docs/drive.md`
  * `/docs/classroom.md`
  * `/docs/email.md`
  * `/docs/ai.md`
  * `/docs/architecture.md`

## Project Name

DeadlineAI

## Product Vision

DeadlineAI is a desktop AI assistant designed specifically for university students.

It acts as a personal academic operating system by combining:

* Google Gemini
* Google Calendar
* Google Drive
* Google Classroom
* Gmail
* Google Meet

The goal is to reduce academic workload and automate repetitive tasks.

---

# Authentication

## Google Sign In

User authenticates only once using Google OAuth.

Required scopes:

### Google Calendar

* Read calendar events
* Create events
* Update events

### Google Drive

* Read user files
* Search files

### Gmail

* Read latest emails

### Google Classroom

* Read assignments
* Read deadlines

### Google Meet

* Create meeting links

### Gemini API

* Primary AI engine

Store authentication securely.

Use refresh tokens to maintain long-term sessions.

---

# Main Interface

## Layout

Modern desktop UI inspired by:

* ChatGPT
* Notion
* Linear
* Raycast

Theme:

* One Dark

Layout:

### Left Sidebar

* Chat
* Calendar
* Drive
* Meet
* Classroom
* Email
* Insights
* Settings

### Center Content

Current selected page.

### Bottom Prompt Area

Persistent AI prompt box available globally.

User can ask:

* Schedule my study session tomorrow
* Find my machine learning spreadsheet
* Show upcoming deadlines
* Summarize today's emails
* Create a meeting for my group project

### Right Panel

Optional contextual information:

* Upcoming deadlines
* Today's schedule
* AI suggestions

---

# Features

## 1. AI Chat

Gemini-powered conversational assistant.

Capabilities:

* Understand user context
* Access Calendar
* Access Drive
* Access Classroom
* Access Gmail
* Create actions automatically

Example:

User:

"Create a study schedule for Linear Algebra next week."

AI:

* Creates calendar events
* Displays preview
* Requests confirmation
* Syncs to Google Calendar

---

## 2. Smart Calendar Creator

Dedicated tab.

Workflow:

1. User clicks "Create Schedule".
2. User describes activity naturally.

Examples:

* Study machine learning every evening for two weeks.
* Prepare presentation before Friday.
* Allocate time for final exams.

AI generates:

* Event title
* Duration
* Recurrence
* Time blocks

Preview before saving.

After confirmation:

Automatically create Google Calendar events.

---

## 3. Drive Quick Access

Dedicated tab.

Show:

* Frequently opened files
* Recently modified files
* AI-recommended files

Search examples:

* Machine learning assignment
* Linear algebra spreadsheet
* PKM proposal

Results:

* Open directly in browser
* Launch using system default handler

---

## 4. Google Meet Scheduler

Dedicated tab.

Workflow:

1. User describes meeting.
2. AI extracts:

   * Participants
   * Date
   * Time
   * Duration
3. System creates:

   * Google Calendar Event
   * Google Meet Link
4. Invitations are sent automatically.

Display generated meeting link.

---

## 5. Classroom Deadline Monitor

Dedicated tab.

Display:

* Upcoming assignments
* Overdue assignments
* Assignment priorities

Sort by:

* Urgency
* Course
* Deadline

AI can suggest study schedules based on deadlines.

---

## 6. Email Dashboard

Dedicated tab.

Show:

* Latest emails
* Important emails
* Academic emails

AI features:

* Summarization
* Priority detection
* Action recommendations

Example:

"Lecturer requested report revision before Tuesday."

---

## 7. Daily Insights

Most important feature.

Analyze:

* Calendar
* Classroom
* Gmail
* Drive activity

Generate daily briefing.

Examples:

### Today's Priorities

* Complete Machine Learning Assignment
* Attend Group Meeting 14:00
* Submit PKM Draft

### Risk Alerts

* 2 assignments due within 48 hours
* No study time allocated for Linear Algebra

### Productivity Suggestions

* Free time available 19:00-21:00
* Recommended study block: Data Mining

This page should feel like a personal academic dashboard.

---

# AI Agent System

Create internal tools available to Gemini:

## Calendar Tool

* Create event
* Update event
* Delete event
* Search event

## Drive Tool

* Search files
* Open files

## Classroom Tool

* Fetch assignments
* Fetch deadlines

## Email Tool

* Read latest emails
* Summarize emails

## Meet Tool

* Generate meetings

Gemini should use tool-calling architecture.

---

# Data Storage

Local database:

SQLite

Store:

* Chat history
* Preferences
* AI memories
* Cached metadata

Do not store sensitive Google credentials unencrypted.

---

# Architecture

Use Clean Architecture.

Layers:

* Presentation
* Application
* Domain
* Infrastructure

Feature modules:

* auth
* ai
* calendar
* drive
* classroom
* email
* meet
* insights
* settings

All modules must be isolated.

---

# Recommended Stack

Desktop:

* Flutter Desktop

Backend Layer:

* Dart

Database:

* SQLite

Authentication:

* Google OAuth

AI:

* Google Gemini

State Management:

* Riverpod

Local Storage:

* Drift

Routing:

* Go Router

Dependency Injection:

* Riverpod Providers

---

# Deliverables

Generate:

1. Complete project architecture.
2. Folder structure.
3. Database schema.
4. Feature specifications.
5. UI wireframes.
6. Clean Architecture implementation.
7. API integration layer.
8. Documentation inside `/docs`.
9. Production-ready code.
10. Build instructions for Linux, Windows, and macOS.
