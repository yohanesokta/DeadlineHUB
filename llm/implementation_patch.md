# Patch Update v2

Apply the following updates to the existing DeadlineAI codebase.

These requirements are mandatory and override previous behavior.

---

# 1. AI Activity Log System

Current behavior is unacceptable.

The user only sees a loading state while AI is working.

Users must always know what the AI is doing.

---

## Requirement

Create a live AI activity timeline directly below:

```text
Ask DeadlineAI anything...
```

Display real-time execution logs.

Examples:

```text
● Analyzing request...
```

```text
● Reading Google Calendar...
```

```text
● Fetching Classroom assignments...
```

```text
● Searching related Drive files...
```

```text
● Reading recent emails...
```

```text
● Building response...
```

```text
● Creating calendar event...
```

```text
● Generating Google Meet link...
```

```text
● Synchronizing changes...
```

---

## UX Goal

The application must feel alive.

The user must never wonder:

"Is the AI frozen?"

The user must always know:

* what is happening
* what data source is being used
* which step is currently running

---

## Technical Requirement

Implement:

```text
AiTaskTimeline
```

State examples:

```text
Pending
Running
Completed
Failed
```

Every tool call must emit progress events.

Examples:

Calendar Tool

Drive Tool

Classroom Tool

Gmail Tool

Meet Tool

Gemini Tool

---

# 2. User Profile Synchronization

Current implementation is incorrect.

User account information does not update from Google.

---

## Requirement

After successful login:

Fetch:

* Google account name
* Google email
* Google profile image

Store locally.

Display inside sidebar.

Display inside settings.

Display inside profile menu.

---

## Example

Sidebar:

```text
John Doe
john@example.com
```

Profile picture must use actual Google profile photo.

No placeholders after login.

---

## Refresh Behavior

On every application startup:

Refresh profile information.

If user changes profile photo in Google:

The application must update automatically.

If user changes display name:

The application must update automatically.

---

# 3. Global Background Synchronization

Current behavior:

Data loads only when a tab is opened.

This is unacceptable.

---

## New Behavior

Immediately after authentication:

Start background synchronization.

Modules:

* Calendar
* Classroom
* Gmail
* Drive

All modules begin syncing simultaneously.

Users should not need to open tabs to trigger data loading.

---

## Startup Flow

Application Start

↓

Authentication Validation

↓

Initialize Services

↓

Background Sync Starts

↓

Open UI

---

# 4. Stale Data Cache Strategy

Current behavior causes empty screens while syncing.

This creates poor UX.

---

## Requirement

During synchronization:

Display last known successful data.

Never clear UI while refreshing.

---

### Correct Behavior

User has:

5 calendar events

New sync starts

Display:

5 existing events

while:

Refreshing...

appears in background

When new data arrives:

Replace old data.

---

### Forbidden Behavior

Display:

Loading...

Empty Screen

No Data

while synchronization is still running.

---

# 5. No Dummy Data Policy Reinforcement

No fake content may ever be shown.

---

## If cache exists

Show cached data.

---

## If cache does not exist

Show:

```text
No calendar events available.
```

```text
No classroom assignments available.
```

```text
No emails available.
```

```text
No drive files available.
```

---

## Never show

Fake events

Fake assignments

Fake emails

Fake schedules

Sample records

Placeholder records

Generated examples

---

# 6. Synchronization Status Center

Add a synchronization status widget.

Sidebar footer:

```text
Calendar     Synced 2m ago
Drive        Syncing...
Classroom    Synced 30s ago
Gmail        Synced 1m ago
```

If failure occurs:

```text
Gmail Sync Failed
```

Provide retry action.

---

# 7. Repository Architecture

Create dedicated services.

```text
SyncCoordinator
```

Responsible for:

* Startup sync
* Background refresh
* Retry policy
* Cache updates

---

```text
CacheRepository
```

Responsible for:

* Last successful data
* Offline access
* Data persistence

---

```text
SyncStatusRepository
```

Responsible for:

* Sync state
* Last sync timestamp
* Failure tracking

---

# 8. User Experience Goal

The application should feel like:

Google Workspace is continuously connected.

The user should never experience:

* empty screens
* mysterious loading states
* disappearing data
* hidden AI processing

The user should always see:

* current sync status
* AI execution status
* last successful data
* real account identity

The application must feel responsive even while background synchronization is running.
