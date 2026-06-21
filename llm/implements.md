# Implementation Requirements

Continue implementing the project.

All placeholder data, mock data, fake responses, hardcoded examples, and demonstration content must be removed.

The application must operate only with real data sources.

---

# Authentication Gate

Authentication is mandatory.

The main application must never be accessible before authentication succeeds.

## Startup Flow

Application launch:

1. Check local authentication state.
2. Check Google OAuth validity.
3. Check Gemini API Key availability.

If either authentication or API key is missing:

* Display authentication overlay.
* Block all application functionality.
* Disable navigation.
* Disable chat.
* Disable calendar.
* Disable drive.
* Disable classroom.
* Disable email.
* Disable meet.
* Disable insights.

The user must complete authentication before accessing the application.

---

# Authentication Screen

Show a dedicated authentication interface.

Required fields:

## Google Account

Button:

"Continue with Google"

Requirements:

* OAuth 2.0
* Offline access enabled
* Refresh token support
* Long-term session persistence

Required scopes:

### Google Calendar

https://www.googleapis.com/auth/calendar

### Google Drive

https://www.googleapis.com/auth/drive.readonly

### Gmail

https://www.googleapis.com/auth/gmail.readonly

### Google Classroom

https://www.googleapis.com/auth/classroom.courses.readonly

https://www.googleapis.com/auth/classroom.coursework.me.readonly

### User Profile

openid

email

profile

---

## Gemini API Key

Input:

* Password field
* Hidden by default
* Show/Hide toggle

Validation:

* Cannot be empty
* Verify against Gemini API before saving
* Reject invalid keys

Store securely.

Never hardcode API keys.

---

# Authentication Overlay

If authentication becomes invalid:

Examples:

* Refresh token expired
* OAuth revoked
* Gemini key deleted
* Gemini key invalid

Then:

1. Display full-screen authentication overlay.
2. Blur background.
3. Disable application interaction.
4. Redirect user to re-authentication flow.

The application must never continue operating with invalid credentials.

---

# Real Data Policy

Strict rule:

Do not use:

* Mock data
* Placeholder data
* Demo content
* Fake assignments
* Fake emails
* Fake files
* Static JSON samples

All views must load data from real providers.

---

# Calendar Module

Source:

Google Calendar API

Requirements:

* Fetch actual events
* Create actual events
* Update actual events
* Delete actual events

No local fake events.

---

# Drive Module

Source:

Google Drive API

Requirements:

* Search user files
* Open actual files
* Display actual metadata

No generated file lists.

---

# Gmail Module

Source:

Gmail API

Requirements:

* Load actual emails
* Summarize actual email content using Gemini

No fake inbox entries.

---

# Classroom Module

Source:

Google Classroom API

Requirements:

* Load actual courses
* Load actual assignments
* Load actual deadlines

No generated coursework.

---

# Google Meet Module

Source:

Google Calendar ConferenceData

Requirements:

* Create actual Meet links
* Store actual conference identifiers

No placeholder URLs.

---

# Insights Module

Generate insights only from:

* Calendar events
* Gmail messages
* Classroom deadlines
* Drive activity

Never fabricate recommendations without underlying data.

---

# Secure Storage

Store:

* OAuth Tokens
* Refresh Tokens
* Gemini API Key

Use platform secure storage.

Examples:

Linux:

* libsecret

Windows:

* Credential Manager

macOS:

* Keychain

Never store secrets in plain SQLite.

---

# Offline Handling

If network unavailable:

Display:

* Authentication status
* Last synchronization time
* Cached metadata

Mark all stale data clearly.

Do not generate replacement fake content.

---

# Error Handling

Every Google API request must have:

* Retry mechanism
* Expired token handling
* Network failure handling
* Permission error handling

Unauthorized requests must trigger re-authentication automatically.

---

# Development Rule

Before merging any feature:

Ask:

"Does this feature use real Google Workspace data?"

If the answer is no:

Do not implement the feature.

No dummy data.
No mock services.
No fake repositories.
No placeholder UI states pretending to be real data.

