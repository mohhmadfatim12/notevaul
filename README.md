# NoteVault — Smart Notes Organizer

> Organize your thoughts, tasks, and ideas with complete privacy and zero cloud dependencies.

**NoteVault** is an original, production-grade, 100% offline-first note-taking and personal organization application built with **Flutter**, **Dart**, and local **SQLite** (`sqflite`). Designed from the ground up for speed, reliability, and security, NoteVault stores all personal data locally on the user's device with zero cloud tracking, zero external servers, and zero mandatory accounts.

---

## 📸 Screenshots & Previews

The app features an adaptive Material 3 user interface with dynamic theme switching and smooth screen transitions:

- **Dashboard / Home Screen**: Real-time aggregate statistics, weekly activity bar chart, and upcoming reminders agenda.
- **Notes Feed**: Dual view modes with color cards, folder badges, tag chips, and instant pin/favorite markers.
- **Rich Note Editor**: Live debounced auto-save, interactive word/character counter, color selection row, and reading-time estimation.
- **Organization Center**: Hierarchical folder management, tag managers, and color indexing.
- **Advanced Local Search**: Instant multi-attribute search with text highlighting and saved recent queries.
- **Trash & Soft Deletion**: 30-day automatic retention countdown and one-tap restore.
- **Security & Lock**: Salted SHA-256 PIN entry and biometric verification.

---

## ✨ Features Overview

### 1. Notes Management
- **Full CRUD Support**: Create, edit, soft-delete, restore, and permanently delete notes.
- **Debounced Auto-Save**: Auto-saves every 800ms of typing inactivity with interactive "Saved" status feedback.
- **Validation**: Enforces non-empty title/body prevention to eliminate accidental blank drafts.
- **8 Curated Color Accents**: Default Slate, Soft Blue, Emerald Green, Warm Amber, Rose Pink, Deep Purple, Ocean Cyan, and Charcoal.
- **Productivity Counter**: Live calculation of word count, character count, and reading time (200 WPM benchmark).
- **Flexible Sorting**: Sort by Newest Updated, Oldest Updated, Newest Created, Oldest Created, Title A–Z, and Title Z–A.
- **Bulk Multi-Select**: Long-press to trigger batch actions: Archive, Favorite, Pin, Move to Folder, Assign Tags, and Delete.

### 2. Folders & Notebooks
- Create custom folders with personalized names, color labels, and icon glyphs.
- Automatic counter tracking active notes in each folder.
- Deletion Protection: Choose to reassign notes to "Unfiled" or delete them together with the folder.

### 3. Tags & Taxonomies
- Multi-tag assignment: Associate any note with multiple tags.
- Tag Management screen with real-time note counts.
- Non-destructive tag deletion preserves note contents.

### 4. Advanced Local Search
- Deep full-text query matching across note titles, contents, folders, and tags.
- Visual keyword match highlighting in results list.
- Multi-filter bottom sheet: Filter results by folder, tag, color, or status.
- Recent search history saved locally with 1-tap query execution and clear history.

### 5. Trash System & Auto-Cleanup
- Two-stage soft deletion: Trashed notes remain restorable for 30 days.
- Visual countdown badge displaying days remaining before permanent deletion.
- Automated 30-day purge running on app startup.
- Single-note restore, permanent single-note deletion, or empty entire trash with confirmation.

### 6. Local Reminders & Notifications
- Schedule specific dates and times for note alerts.
- Android system notification channel (`Importance.high`, `Priority.high`).
- Timezone-aware local scheduling powered by `flutter_local_notifications` and `timezone`.
- Auto-cancels scheduled notifications when a note is archived, trashed, or deleted.
- Reschedules upcoming reminders on device reboot via `RECEIVE_BOOT_COMPLETED`.

### 7. Document Export & Native Sharing
- **Vector PDF Export**: Generates professional A4 PDF documents including note title, folder hierarchy, tags, timestamps, and formatted body text.
- **Plain Text (.txt) Export**: Direct integration with the native Android Share Sheet via `share_plus`.
- Save files directly to local device storage.

### 8. Full Offline Backup & Restoration
- Complete JSON backup containing notes, folders, tags, junction mappings, and reminder timestamps.
- Structural schema validation preventing corrupted or incompatible imports.
- Atomic SQLite restoration replacing records inside a single transaction.

### 9. On-Device Security & Privacy
- 4-digit or 6-digit PIN setup with confirmation guard.
- SHA-256 one-way salted hashing with zero plain-text storage.
- Biometric unlock (Fingerprint / Face Unlock) via `local_auth` with automatic PIN fallback.
- Inactivity auto-lock options: Immediate, 1 min, 5 min, 15 min.

### 10. Dashboard & Analytics
- Aggregate cards: Total Notes, Folders, Tags, Pinned, Favorites, and Trashed.
- Interactive weekly activity bar chart using `fl_chart`.
- Agenda feed for upcoming note reminders.
- Quick-action shortcuts for rapid productivity.

---

## 🛠 Tech Stack & Dependencies

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| **Framework** | Flutter | 3.47+ (Stable) | Cross-platform UI toolkit |
| **Language** | Dart | 3.13+ | Object-oriented client language |
| **Database** | `sqflite` | ^2.4.5 | Local embedded SQLite database |
| **State** | `provider` | ^6.1.5 | Reactive ChangeNotifier state management |
| **Storage** | `shared_preferences` | ^2.5.6 | Key-value settings and preferences |
| **Notifications** | `flutter_local_notifications` | ^22.3.3 | Local Android notification channel |
| **Timezone** | `timezone` | ^0.11.2 | Timezone calculations for reminders |
| **PDF Generation** | `pdf` & `printing` | ^3.13.1 / ^5.15.1 | Vector PDF document compilation and printing |
| **Sharing** | `share_plus` | ^13.3.1 | Native Android share sheet integration |
| **File Picker** | `file_picker` | ^13.3.0 | Local storage document file picker |
| **Charts** | `fl_chart` | ^1.3.0 | Analytics bar chart rendering |
| **Biometrics** | `local_auth` | ^3.0.2 | Fingerprint and face authentication |
| **Security** | `crypto` | ^3.0.8 | SHA-256 cryptographic hashing |
| **Identifiers** | `uuid` | ^4.6.0 | RFC 4122 v4 unique primary keys |
| **Formatting** | `intl` | ^0.20.3 | Date, time, and numeric formatting |

All packages use permissive open-source licenses (MIT, Apache 2.0, BSD-3-Clause).

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point & dependency injection
├── app.dart                           # Root MaterialApp, theme binding, and navigation
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Theme palettes & 8 note color options
│   │   ├── app_dimensions.dart        # Margins, paddings, icon sizes, corner radii
│   │   └── app_strings.dart           # User-facing string constants
│   ├── extensions/
│   │   ├── date_extensions.dart       # Relative time, formatting, 30-day trash expiry
│   │   └── string_extensions.dart     # Word count, char count, reading time
│   ├── theme/
│   │   ├── app_theme.dart             # Theme facade and accent colors
│   │   ├── light_theme.dart           # Material 3 light theme specification
│   │   └── dark_theme.dart            # Material 3 dark theme specification
│   └── utils/
│       ├── debouncer.dart             # Debounce timer for high-frequency keystrokes
│       ├── result.dart                # Functional Result<T> monad
│       └── validators.dart            # Input validation routines
├── data/
│   ├── datasources/local/
│   │   ├── database_helper.dart       # SQLite database lifecycle, schema, indexes
│   │   ├── folder_local_datasource.dart
│   │   ├── note_local_datasource.dart
│   │   ├── search_history_datasource.dart
│   │   └── tag_local_datasource.dart
│   ├── models/
│   │   ├── backup_model.dart          # JSON backup serialization model
│   │   ├── folder.dart                # Folder database model
│   │   ├── note.dart                  # Note database model
│   │   ├── note_tag.dart              # Junction table model
│   │   ├── search_history.dart        # Search query history model
│   │   └── tag.dart                   # Tag database model
│   └── repositories/
│       ├── backup_repository_impl.dart
│       ├── folder_repository_impl.dart
│       ├── note_repository_impl.dart
│       ├── search_repository_impl.dart
│       └── tag_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── folder_entity.dart         # Domain folder representation
│   │   ├── note_entity.dart           # Domain note representation
│   │   └── tag_entity.dart            # Domain tag representation
│   ├── repositories/
│   │   ├── backup_repository.dart
│   │   ├── folder_repository.dart
│   │   ├── note_repository.dart
│   │   ├── search_repository.dart
│   │   └── tag_repository.dart
│   └── usecases/
│       ├── assign_tags.dart
│       ├── create_backup.dart
│       ├── create_folder.dart
│       ├── create_note.dart
│       ├── delete_note.dart
│       ├── restore_backup.dart
│       ├── restore_note.dart
│       ├── search_notes.dart
│       └── update_note.dart
├── presentation/
│   ├── providers/
│   │   ├── folders_provider.dart
│   │   ├── notes_provider.dart
│   │   ├── search_provider.dart
│   │   ├── security_provider.dart
│   │   ├── settings_provider.dart
│   │   └── tags_provider.dart
│   ├── screens/
│   │   ├── about/about_screen.dart
│   │   ├── archive/archive_screen.dart
│   │   ├── backup/backup_screen.dart
│   │   ├── dashboard/dashboard_screen.dart
│   │   ├── favorites/favorites_screen.dart
│   │   ├── folders/
│   │   │   ├── create_edit_folder_dialog.dart
│   │   │   ├── folder_details_screen.dart
│   │   │   └── folder_list_screen.dart
│   │   ├── note_editor/note_editor_screen.dart
│   │   ├── notes/
│   │   │   ├── note_details_screen.dart
│   │   │   ├── notes_screen.dart
│   │   │   └── pinned_notes_screen.dart
│   │   ├── onboarding/onboarding_screen.dart
│   │   ├── reminders/reminders_screen.dart
│   │   ├── search/search_screen.dart
│   │   ├── security/
│   │   │   ├── pin_setup_screen.dart
│   │   │   └── pin_unlock_screen.dart
│   │   ├── settings/settings_screen.dart
│   │   ├── splash/splash_screen.dart
│   │   ├── tags/
│   │   │   ├── create_edit_tag_dialog.dart
│   │   │   ├── tag_details_screen.dart
│   │   │   └── tag_list_screen.dart
│   │   └── trash/trash_screen.dart
│   └── widgets/
│       ├── color_picker_row.dart
│       ├── confirmation_dialog.dart
│       ├── custom_app_bar.dart
│       ├── empty_state.dart
│       ├── error_view.dart
│       ├── folder_card.dart
│       ├── loading_indicator.dart
│       ├── note_card.dart
│       ├── search_field.dart
│       └── tag_chip.dart
└── services/
    ├── backup_service.dart
    ├── database_service.dart
    ├── export_service.dart
    ├── notification_service.dart
    ├── preference_service.dart
    └── security_service.dart
```

---

## 🚀 Setup & Execution Guide

### Prerequisites
- **Flutter SDK**: 3.47+ (Channel stable)
- **Dart SDK**: 3.13+
- **Android SDK**: API Level 24+ (`minSdk = 24`), target API 34+
- **Java Development Kit**: JDK 17 or JDK 21 LTS

### 1. Installation
```bash
# Clone the repository
git clone https://github.com/your-username/notevault.git
cd notevault

# Install package dependencies
flutter pub get
```

### 2. Verify Code Quality & Tests
```bash
# Run static analysis (0 errors, 0 warnings enforced)
flutter analyze

# Execute complete test suite
flutter test
```

### 3. Run Locally on Android Device or Emulator
```bash
flutter run
```

### 4. Build Production Release APK
```bash
flutter build apk --release
```
The compiled APK will be output at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🎨 Customization & Rebranding Guide

### 1. How to Rename the App
1. **Android Label**: Edit `android:label="YourAppName"` in `android/app/src/main/AndroidManifest.xml`.
2. **App Title**: Edit `static const String appName = 'YourAppName';` in `lib/core/constants/app_strings.dart`.
3. **Project Name**: Update `name: yourappname` in `pubspec.yaml`.

### 2. How to Change the Package Name / Application ID
1. In `android/app/build.gradle.kts`:
   ```kotlin
   defaultConfig {
       applicationId = "com.yourcompany.appname"
   }
   android {
       namespace = "com.yourcompany.appname"
   }
   ```
2. Move `android/app/src/main/kotlin/com/notevault/notevault/MainActivity.kt` to match the new package hierarchy (e.g., `android/app/src/main/kotlin/com/yourcompany/appname/MainActivity.kt`) and update the `package` statement at line 1.

### 3. How to Change App Colors & Theme
All theme tokens and color constants are centralized in `lib/core/constants/app_colors.dart`.
- Change primary brand color: Modify `AppColors.primary`.
- Modify accent choices: Modify `AppTheme.accentColorOptions` in `lib/core/theme/app_theme.dart`.

### 4. How to Update App Launcher Icon
1. Replace your custom 512x512 PNG at `assets/icon/app_icon.png`.
2. Add `flutter_launcher_icons` to `dev_dependencies` in `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/icon/app_icon.png"
   ```
3. Run `dart run flutter_launcher_icons`.

---

## 💾 Database & Backup File Format

### SQLite Embedded Database
NoteVault stores all data inside an offline SQLite database (`notevault.db`) in the application's private app data directory. See [`DATABASE_SCHEMA.md`](DATABASE_SCHEMA.md) for full SQL schema, relationships, and index definitions.

### Backup JSON Structure
When exporting a full backup via Settings or the Backup screen, NoteVault creates a portable, human-readable JSON document:

```json
{
  "version": 1,
  "app_name": "NoteVault",
  "exported_at": 1729864800000,
  "folders": [
    {
      "id": "uuid-v4",
      "name": "Work Projects",
      "color": 4283215696,
      "icon": "folder",
      "created_at": 1729864800000,
      "updated_at": 1729864800000
    }
  ],
  "tags": [
    {
      "id": "uuid-v4",
      "name": "urgent",
      "color": 4293278005,
      "created_at": 1729864800000
    }
  ],
  "notes": [
    {
      "id": "uuid-v4",
      "folder_id": "uuid-v4",
      "title": "Roadmap Note",
      "body": "Detailed content goes here...",
      "color": 0,
      "is_pinned": 1,
      "is_favorite": 0,
      "is_archived": 0,
      "is_deleted": 0,
      "reminder_at": null,
      "created_at": 1729864800000,
      "updated_at": 1729864800000,
      "deleted_at": null
    }
  ],
  "note_tags": [
    {
      "note_id": "uuid-v4",
      "tag_id": "uuid-v4"
    }
  ]
}
```

---

## ❓ Troubleshooting Section

| Problem | Cause | Solution |
|---|---|---|
| **Notifications don't fire** | Android 13+ requires notification permission | Grant permission when prompted or in Android App Settings > Notifications. |
| **Biometric prompt not showing** | Device does not have biometric hardware or no fingerprints are enrolled | NoteVault automatically falls back to PIN lock safely. |
| **File Picker fails on older Android** | Storage permission missing | NoteVault uses Android Storage Access Framework (SAF) which requires no runtime storage permissions on API 24+. |
| **Backup restore says "Invalid file structure"** | Selected JSON file lacks required schema keys | Ensure you are selecting a valid backup file generated by NoteVault. |

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
