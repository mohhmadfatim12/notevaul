# NoteVault — Complete User & Technical Documentation

NoteVault is a production-grade, 100% offline-first productivity and personal knowledge management application built with Flutter and SQLite. This document provides complete operational, architectural, and customization guides.

---

## 1. Product Overview

### 1.1 Value Proposition
In an ecosystem dominated by cloud-tethered note applications that require account registration, internet connectivity, and background subscriptions, NoteVault provides absolute privacy, instant local performance, and zero server reliance. All notes, folders, tags, and settings exist strictly within the device's secure local SQLite database sandbox.

### 1.2 System Compatibility
- **Operating System**: Android 7.0 (API Level 24) through Android 15 / 16 (API Level 35/36).
- **Core Architecture**: ARM64-v8a, ARMeabi-v7a, x86_64.
- **Form Factors**: Optimized for Android smartphones and tablets with adaptive portrait and landscape layouts.
- **Hardware Security**: Supports Android BiometricPrompt (Fingerprint, Face Recognition) and hardware-backed keystores.

---

## 2. Feature Guide

### 2.1 Notes Engine
- **Note Composition**: Rich title and multi-paragraph body editor.
- **Auto-Save Engine**: Features an active 800ms debounce loop. Whenever changes are typed, NoteVault pauses and commits updates without UI jank. A "Saved" chip indicates successful database synchronization.
- **Color Labeling**: 8 distinct color palettes (Default Slate, Soft Blue, Emerald Green, Warm Amber, Rose Pink, Deep Purple, Ocean Cyan, Charcoal). Each color provides light and dark mode optical surface values.
- **Productivity Counter**: Live header metrics display current word count, character count, and estimated reading time (200 words-per-minute benchmark).
- **Organization Flags**:
  - `Pinned`: Anchors notes to the top of the All Notes list and displays them in the Pinned Notes screen.
  - `Favorite`: Marks notes for priority review.
  - `Archived`: Hides completed or reference notes from the primary feed while preserving full searchability.
  - `Trash`: Soft-deleted notes entering the 30-day auto-expiry retention period.

### 2.2 Folders System
- Create, rename, customize color, and assign icons to folders.
- Automatic note counter reflects all active (non-trashed) notes within each folder.
- Deletion Protection: Deleting a folder prompts the user to either:
  1. Move its notes to "Unfiled" (preserving all note contents and tags).
  2. Permanently delete all contained notes.

### 2.3 Tags System
- Multi-tag tagging: Notes can belong to any number of tags simultaneously.
- Tag deletion safely decouples the tag from notes without deleting the notes themselves.
- Duplicate prevention: Tag names are unique and sanitized.

### 2.4 Advanced Search
- Real-time instant queries across note titles, body texts, folder names, and tags.
- Visual keyword highlighting inside note cards.
- Search filter sheet: Filter search scope by folder, tag, color, or status (All, Pinned, Favorites, Archived).
- Search history: Locally stored recent queries with 1-tap re-run and history clearing.

### 2.5 Reminders & Notification System
- Date and time picker with future-validation.
- Android system notification channels: Registered with `Importance.high` and `Priority.high`.
- Timezone handling: Native `timezone` library schedules exact alerts.
- Auto-cancellation: If a note with a scheduled reminder is trashed or deleted, its pending notification is automatically unscheduled.

### 2.6 Export & Sharing
- **PDF Export**: Generates an A4 formatted document containing note title, creation/updated timestamps, folder hierarchy, tag badges, and text body. Preview and print dialogs open natively.
- **TXT Export**: Formats the note into plain text and opens the native Android Share Sheet to send via messaging apps, Bluetooth, or local file managers.

### 2.7 Backup & Restore
- **Export Backup**: Packages all SQLite tables (`notes`, `folders`, `tags`, `note_tags`) into a single structured `.json` document.
- **Restore Backup**: Validates the selected `.json` backup structure, verifies table schemas, displays a confirmation dialog, wipes existing local tables inside an atomic SQLite transaction, and inserts the restored records.

### 2.8 Security System
- **PIN Lock**: Supports 4-digit and 6-digit passcodes.
- **SHA-256 Hashing**: Passcodes are hashed with SHA-256 before storing in local encrypted preferences. Passcodes are never stored or logged in plain text.
- **Biometric Unlock**: Integrated with `local_auth` to authenticate using device fingerprint or face recognition, falling back to PIN automatically.
- **Inactivity Timeout**: Configurable auto-lock delay (Immediate, 1 min, 5 min, 15 min).

---

## 3. Developer & Customization Guide

### 3.1 Changing App Name
1. **Android App Name**: Update `android:label="NoteVault"` in `android/app/src/main/AndroidManifest.xml`.
2. **Flutter Title**: Update `AppStrings.appName` in `lib/core/constants/app_strings.dart`.
3. **Package Configuration**: Update `name: notevault` in `pubspec.yaml`.

### 3.2 Changing Android Package Name / Application ID
1. In `android/app/build.gradle.kts`:
   ```kotlin
   defaultConfig {
       applicationId = "com.yourcompany.appname"
   }
   ```
2. Update the namespace in `android/app/build.gradle.kts`:
   ```kotlin
   namespace = "com.yourcompany.appname"
   ```
3. Move `android/app/src/main/kotlin/com/notevault/notevault/MainActivity.kt` to match your new directory structure (e.g., `com/yourcompany/appname/MainActivity.kt`) and update the `package` declaration at the top of the file.

### 3.3 Customizing Color Themes
All app theme tokens are centralized in:
- `lib/core/constants/app_colors.dart`
- `lib/core/theme/light_theme.dart`
- `lib/core/theme/dark_theme.dart`
- `lib/core/theme/app_theme.dart`

To change the primary brand color, update `AppColors.primary` and `AppTheme.accentColorOptions`.

### 3.4 Customizing Launcher Icons
1. Place your 512x512 PNG app icon at `assets/icon/app_icon.png`.
2. Configure `flutter_launcher_icons` in `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/icon/app_icon.png"
   ```
3. Run `dart run flutter_launcher_icons`.

---

## 4. Troubleshooting & FAQ

### Q: Why are notifications not firing on some Android devices?
A: Android 13+ (API 33+) requires the user to explicitly grant the `POST_NOTIFICATIONS` runtime permission. NoteVault automatically requests this permission on first reminder scheduling. Additionally, devices with aggressive battery savers (e.g. Xiaomi MIUI/HyperOS, Huawei EMUI, Samsung OneUI) may require allowing "Unrestricted Battery" for NoteVault in Android Settings.

### Q: How does Trash auto-cleanup work?
A: Whenever the app starts or when the Trash screen is opened, NoteVault runs a query:
```sql
DELETE FROM notes WHERE is_deleted = 1 AND deleted_at < (currentTime - 30_DAYS_IN_MS);
```
Notes older than 30 days are permanently purged without blocking the UI thread.

### Q: Can backup files be transferred between different Android devices?
A: Yes! The JSON backup file is completely self-contained. You can export a backup on one phone, send the `.json` file to another phone via Bluetooth, Google Drive, or messaging apps, and restore it seamlessly in NoteVault.
