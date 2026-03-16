# Changelog

All notable changes to the **NoteVault** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-27

### Added
- **Core Architecture & Foundation**
  - Clean layered architecture separating Presentation, Domain, Data, and Services.
  - Multi-tier Provider state management for predictable reactivity and isolated view state.
  - Comprehensive Material 3 design system supporting Light, Dark, and System Theme modes.
  - Eight curated note accent color palettes with light and dark mode optical surface resolution.
  - Full offline-first local SQLite engine using `sqflite` with automatic database schema creation, versioning, and migration hooks.

- **Notes Management**
  - Full CRUD operations: Create, read, update, soft-delete, and permanently delete notes.
  - Debounced auto-save engine (800ms) with interactive "Saved" visual feedback indicator.
  - Input validation preventing accidental saving of blank notes.
  - Quick multi-attribute toggles: Pin to top, Favorite, Archive, and Move to Trash.
  - Real-time productivity metrics: Word count, character count, and estimated reading time.
  - Six-way flexible sorting: Newest Updated, Oldest Updated, Newest Created, Oldest Created, Title A–Z, Title Z–A.
  - Long-press multi-selection mode with bulk actions: Archive, Favorite, Pin, Delete, Change Folder, and Assign Tags.

- **Folders & Hierarchy**
  - Dedicated Folder entity supporting custom names, 8 custom color accents, and icon identifiers.
  - Dynamic note-to-folder relationships with real-time note count counters.
  - Safe folder deletion workflow prompting the user to either reassign notes to "Unfiled" or remove them.
  - Per-folder detail screens filtering notes by category.

- **Tags & Taxonomies**
  - Multi-tag assignment supporting multiple tags per note.
  - Unique tag validation preventing duplicate tags.
  - Tag management screen with color-coded chips and tag deletion without affecting assigned notes.
  - Filter notes by individual tag.

- **Advanced Local Search Engine**
  - Multi-field indexed search across Note Titles, Bodies, Folders, and Tag names.
  - Dynamic hit highlighting emphasizing matched substrings in title and content.
  - Multi-attribute filter sheet: Folder filter, Tag filter, Color filter, and Status filter.
  - Persistent search history with one-tap query re-execution and history clearing.

- **Soft Deletion & Trash System**
  - Two-stage deletion lifecycle protecting notes against accidental loss.
  - Automated 30-day trash cleanup evaluating expiry timestamps upon startup.
  - Visual days-remaining countdown indicator on each trashed note card.
  - Individual note restore, permanent single note deletion, and empty entire trash with confirmation.

- **Local Timezone-Aware Reminders**
  - Scheduled reminders powered by `flutter_local_notifications` and `timezone`.
  - Exact alarm scheduling surviving app restarts through `RECEIVE_BOOT_COMPLETED`.
  - Notification payload navigation directly opening the referenced note.
  - Automatic notification cancellation when notes are archived, trashed, or deleted.
  - Dedicated Reminders view categorizing notes into Upcoming and Overdue sections.

- **Document Export & Sharing**
  - Single-note vector PDF export with header metadata, tag chips, formatted body, and page numbers via `pdf` and `printing`.
  - Formatted plain-text (.txt) export with direct native system share sheet integration (`share_plus`).
  - App documents directory file saving.

- **Complete Offline Backup & Restoration**
  - Full-fidelity JSON backup exporting notes, folders, tags, note-tag associations, and reminder timestamps.
  - Schema integrity validation preventing restoration of corrupt, empty, or incompatible backup files.
  - Confirmation guard before restoration to prevent accidental data overwrites.

- **App Security & Privacy**
  - SHA-256 salted PIN lock supporting 4-digit and 6-digit passcodes.
  - Biometric authentication (Fingerprint, Face Unlock) via `local_auth` with automatic PIN fallback.
  - Configurable auto-lock timeouts (Immediate, 1 min, 5 min, 15 min).
  - Background snapshot privacy guard concealing app previews in the Android recent apps switcher.

- **Analytics Dashboard & Statistics**
  - Executive dashboard summarizing total notes, active folders, tags, pinned, favorite, and trashed counts.
  - Interactive weekly activity bar chart powered by `fl_chart`.
  - Upcoming reminders agenda module.
  - Quick-action shortcuts for instant note creation, folder creation, search, and backup.

- **Test Suite & Verification**
  - 100% passing test suite across unit models, extensions, validators, security hashing, backup serialization, and widget components.
  - Zero warnings and zero errors in strict `flutter analyze`.
