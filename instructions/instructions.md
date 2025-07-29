# StoryChop iOS Implementation Guide

---

## Overview

StoryChop is an iOS app that helps older adults record and preserve their personal memories through guided voice journaling. The app focuses on simplicity, emotional value, and privacy. Users select a prompt, record their response, and optionally share or replay it.

The MVP (Minimum Viable Product) includes:
- **Core**: Guided voice recording via prompts
- **Essential Add-ons**: Prompt selection, recording archive, playback, sharing, privacy settings

---
## General Notes
- Comply with accessibility guidelines as in WCAG 2.2, the Mobile Accessibility Guidelines and Apple’s own Human Interface Guidelines (HIG)
- Use large fonts, high contrast, and generous touch targets.
- Keep onboarding minimal: 1–2 screens max.
- All recordings should be accessible offline.
- Avoid account creation in MVP.
- Support VoiceOver and accessibility labels.

---

## Navigation Flow

### Main Navigation: Tab Bar + Modal Flow

- **Bottom Tab Bar (Primary Navigation)**
  - **Home**: View saved stories, start a new story
  - **Prompts**: Browse or select prompts
  - **Settings**: Access privacy, export, help

- **Modal Presentation**
  - Used for "Start New Story" flow:
    - Home → Prompt Selection → Recording → Save/Share

- **Push Navigation**
  - Used for viewing story details:
    - Home → Story List → Story Detail (Playback/Share)

### Flow Summary
[Tab Bar]
├── Home
│   ├── Start New Story → Modal → Prompt → Record → Save
│   └── Tap Story → Playback + Share (push)
├── Prompts (optional prompt browsing)
├── Settings

---

## 1. Core Functionality – Guided Voice Recording

### 1.1 Purpose
Allow users to record personal stories in response to a prompt.

### 1.2 Screens Involved
- Home Screen
- Prompt Selection Screen
- Recording Screen

### 1.3 User Interaction & Flow
1. Tap "Start New Story" from the Home screen.
2. View and select a prompt.
3. Enter the Recording screen.
4. Tap to start and stop recording.
5. Save the recording and return to Home.

### 1.4 Implementation Details
- Use `AVAudioRecorder` to manage recording.
- Save recordings to `FileManager` in `.m4a` format.
- Store metadata in `SwiftData`: title, date, prompt, duration, file path.
- Automatically assign title = prompt unless user renames.
- Minimum 5 seconds required to save.
- Prompt appears on screen while recording.

---

## 2. Prompt Selection

### 2.1 Purpose
Help the user choose a meaningful prompt to guide their story.

### 2.2 User Flow
1. Enter Prompt Selection after tapping "Start New Story."
2. View featured prompt or select from categories.
3. Tap "I'm Ready to Record."

### 2.3 Implementation Details
- Maintain a static prompt list grouped by category.
- Randomly rotate a featured prompt.
- Support custom prompt entry.
- Pass selected prompt to Recording screen.

---

## 3. Recording Archive (All Stories (story list))

### 3.1 Purpose
Display all saved stories with playback and metadata.

### 3.2 Screens Involved
- Home Screen
- "All Stories" screen - new screen - add to tab navigation between Prompts and Settings (use appropriate icon)
- Story Detail modal
-- the Story Detail modal uses the recording's heading as the heading on the modal.

### 3.3 User Flow
1. View archive list on Home. 
- The five most recent stories are listed on the Home
- Tap "View all" button to right of "Recent stories" to open "All stories"
2. Tap a story to view its details in the Story Detail modal

### 3.4 Implementation Details
- Fetch and display recordings ordered by date (descending).
- Show prompt title, date, duration.
- Use system player (`AVAudioPlayer`) for playback.
- Display sharing options and transcription (if enabled).
- Persist story metadata in local storage.

---

## 4. Playback

### 4.1 Purpose
Allow users to replay saved recordings.

### 4.2 User Flow
1. Tap on a story from the archive.
2. Press "Play."

### 4.3 Implementation Details
- Use `AVAudioPlayer`.
- Show current time, duration.
- Support play/pause.
- Disable playback for corrupt or missing files.

---

## 5. Sharing

### 5.1 Purpose
Allow users to optionally share a story recording.

### 5.2 User Flow
1. Open a story.
2. Tap “Share.”

### 5.3 Implementation Details
- Generate exportable `.m4a` file.
- Use `UIActivityViewController` for sharing.
- Share by AirDrop, Email, iMessage, or file export.
- Do not auto-upload; sharing must be manual.

---

## 6. Privacy and Data Ownership

### 6.1 Purpose
Ensure users feel safe and in control of their data.

### 6.2 Implementation Details
- Store all data locally in SwiftData unless explicitly exported.
- Add clear privacy statement in Settings.
- Ensure no analytics SDKs capture audio or metadata.

---

## 7. Settings

### 7.1 Purpose
Provide basic app info and user control options.

### 7.2 Implementation Details
- Static text: "Your voice is yours. We never share without your permission."
Settings screen should have following
- Include export all stories function (ZIP or `.m4a` bundle)
- Include basic troubleshooting/help link (email or website - to be provided).
- "Rate the app" which launches the native Apple modal which leads the user to the the App store listing
- "Recommend the app" which launches the native Apple share sheet
- "Submit feedback" which brings the user to their email app to compose an email with the subject "Feedback about StoryChop"
- "Privacy Policy" which opens a page (to be provided)
- each of the options should have a relevant SF symbol as a button which acts in the same way as the text or links in the relevant text

---

## 8. Optional Transcription (if included in MVP)

### 8.1 Purpose
Provide a written version of the spoken memory.

### 8.2 Implementation Details
- Use `SpeechRecognizer` for on-device transcription.
- Process transcript post-recording.
- Allow editing or disabling.
- Display transcript in Story Detail view.

---


