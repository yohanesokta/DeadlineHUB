# Update Project Requirements

Apply the following architectural changes to the existing DeadlineAI codebase.

This update supersedes all previous authentication specifications.

---

# Authentication Strategy

The application uses a hybrid authentication model:

1. Google OAuth credentials are owned by the application developer.
2. Gemini API Key is provided by the user.

Users must never create their own Google Cloud project.

Users must never provide Google OAuth credentials.

Only the Gemini API Key is required from the user.

---

# Developer Configuration

Create environment-based configuration.

Required variables:

```env
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

These credentials belong to the application.

Do not expose them in the UI.

Do not ask the user to provide them.

Load them through environment configuration.

---

# First Launch Experience

When the application starts:

1. Check Google authentication status.
2. Check Gemini API Key existence.
3. Validate Gemini API Key.
4. Validate Google session.

If any requirement fails:

Show authentication screen.

Main application must remain inaccessible.

---

# Authentication Screen

Create a modern onboarding experience.

Theme:

* One Dark
* Clean
* Minimal
* Desktop-first

Required sections:

## Step 1

Google Account

Button:

```text
Continue with Google
```

Behavior:

* Launch OAuth flow
* User selects account
* Store access token
* Store refresh token
* Store expiration time

Required permissions:

Calendar

Drive

Gmail

Classroom

Profile

OpenID

Offline access

---

## Step 2

Gemini API Key

Input:

```text
Gemini API Key
```

Requirements:

* Hidden by default
* Reveal button
* Paste support
* Validation button

Validation process:

1. Send test request to Gemini.
2. Verify response.
3. Reject invalid keys.
4. Save valid keys securely.

Do not continue until validation succeeds.

---

## Step 3

Start Application

Enabled only when:

* Google authentication succeeded
* Gemini validation succeeded

---

# Authentication Guard

Create a global authentication guard.

Behavior:

If Google authentication becomes invalid:

* Show full-screen authentication overlay.
* Block entire application.

If Gemini API Key becomes invalid:

* Show full-screen authentication overlay.
* Block entire application.

If refresh token expires:

* Trigger reauthentication flow.

The application must never operate with invalid credentials.

---

# Secure Storage

Use platform secure storage.

Never store secrets in SQLite.

Store:

```text
google_access_token
google_refresh_token
google_expiry

gemini_api_key
```

Platform support:

Linux:

* libsecret

Windows:

* Credential Manager

macOS:

* Keychain

Implementation:

flutter_secure_storage

---

# Remove Legacy Authentication Logic

Delete:

* Dummy login flows
* Placeholder authentication
* Mock OAuth services
* Sample API key validation
* Fake sessions
* Development authentication bypasses

The application must only support real authentication.

---

# Real Data Enforcement

The entire application must operate on real Google Workspace data.

Forbidden:

* Mock repositories
* Placeholder repositories
* Hardcoded data providers
* Static JSON samples
* Generated fake assignments
* Generated fake emails
* Generated fake calendar events

Allowed:

* Empty states
* Loading states
* Error states

---

# Empty State Policy

If no data exists:

Display:

```text
No calendar events found.
```

```text
No classroom assignments found.
```

```text
No emails found.
```

```text
No drive files found.
```

Never generate sample content.

Never fabricate records.

---

# Integration Status Center

Add a status section in the sidebar.

Display:

✓ Google Connected

✓ Gemini Connected

✓ Calendar Synced

✓ Drive Synced

✓ Gmail Synced

✓ Classroom Synced

Failed integrations:

⚠ Gmail Sync Failed

⚠ Classroom Permission Missing

Users must be able to click failed integrations and resolve them.

---

# Startup Sequence

Required startup flow:

```text
Application Start
        │
        ▼
Load Secure Storage
        │
        ▼
Google Session Exists?
        │
     No ▼
Authentication Screen
        │
        ▼
Gemini Key Exists?
        │
     No ▼
Authentication Screen
        │
        ▼
Validate Google Session
        │
     Fail ▼
Authentication Screen
        │
        ▼
Validate Gemini Key
        │
     Fail ▼
Authentication Screen
        │
        ▼
Open Main Application
```

---

# Documentation Update

Update documentation inside:

/docs/auth.md

Include:

* OAuth architecture
* Secure storage architecture
* Authentication flow
* Session lifecycle
* Token refresh flow
* Gemini validation flow

No documentation should mention mock data or placeholder implementations.

---

# Development Rule

Before implementing any feature:

Ask:

"Does this feature use real Google Workspace data and real authentication?"

If the answer is no:

Do not implement the feature.

No dummy data.
No fake sessions.
No placeholder integrations.
No mocked user experience.

