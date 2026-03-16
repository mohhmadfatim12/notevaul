# NoteVault — SQLite Database Schema Specification

NoteVault uses an offline SQLite embedded database (`notevault.db`) managed via `sqflite`.

---

## 1. Schema Diagram

```
┌─────────────────────────┐             ┌─────────────────────────┐
│         folders         │             │          notes          │
├─────────────────────────┤             ├─────────────────────────┤
│ id: TEXT (PK)           │1           *│ id: TEXT (PK)           │
│ name: TEXT NOT NULL     ├────────────►│ folder_id: TEXT (FK)    │
│ color: INTEGER NOT NULL │             │ title: TEXT NOT NULL    │
│ icon: TEXT              │             │ body: TEXT NOT NULL     │
│ created_at: INTEGER     │             │ color: INTEGER NOT NULL │
│ updated_at: INTEGER     │             │ is_pinned: INTEGER      │
└─────────────────────────┘             │ is_favorite: INTEGER    │
                                        │ is_archived: INTEGER    │
                                        │ is_deleted: INTEGER     │
                                        │ reminder_at: INTEGER    │
                                        │ created_at: INTEGER     │
                                        │ updated_at: INTEGER     │
                                        │ deleted_at: INTEGER     │
                                        └───────────┬─────────────┘
                                                    │ 1
                                                    │
                                                    │ *
                                        ┌───────────▼─────────────┐
                                        │       note_tags         │
                                        ├─────────────────────────┤
                                        │ note_id: TEXT (PK, FK)  │
                                        │ tag_id: TEXT (PK, FK)   │
                                        └───────────▲─────────────┘
                                                    │ *
                                                    │
                                                    │ 1
┌─────────────────────────┐             ┌───────────┴─────────────┐
│     search_history      │             │          tags           │
├─────────────────────────┤             ├─────────────────────────┤
│ id: TEXT (PK)           │             │ id: TEXT (PK)           │
│ query: TEXT NOT NULL    │             │ name: TEXT (UNIQUE)     │
│ searched_at: INTEGER    │             │ color: INTEGER NOT NULL │
└─────────────────────────┘             │ created_at: INTEGER     │
                                        └─────────────────────────┘
```

---

## 2. Table Definitions (DDL)

### 2.1 `folders`
Stores custom notebooks / folders created by the user.
```sql
CREATE TABLE folders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color INTEGER NOT NULL,
  icon TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### 2.2 `notes`
Stores all user notes with support for soft deletion, color labeling, organization flags, and reminders.
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  folder_id TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  color INTEGER NOT NULL,
  is_pinned INTEGER NOT NULL DEFAULT 0,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  reminder_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE SET NULL
);
```

### 2.3 `tags`
Stores unique tags/labels.
```sql
CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  color INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
```

### 2.4 `note_tags`
Many-to-many junction table associating notes with tags.
```sql
CREATE TABLE note_tags (
  note_id TEXT NOT NULL,
  tag_id TEXT NOT NULL,
  PRIMARY KEY (note_id, tag_id),
  FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
);
```

### 2.5 `search_history`
Stores recent search queries for instant recall.
```sql
CREATE TABLE search_history (
  id TEXT PRIMARY KEY,
  query TEXT NOT NULL,
  searched_at INTEGER NOT NULL
);
```

---

## 3. High-Performance Indexing

To guarantee 60 FPS scrolling and instantaneous search responses even with thousands of notes, NoteVault maintains dedicated indexes:

```sql
CREATE INDEX IF NOT EXISTS idx_notes_folder_id ON notes(folder_id);
CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON notes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notes_is_pinned ON notes(is_pinned);
CREATE INDEX IF NOT EXISTS idx_notes_is_favorite ON notes(is_favorite);
CREATE INDEX IF NOT EXISTS idx_notes_is_archived ON notes(is_archived);
CREATE INDEX IF NOT EXISTS idx_notes_is_deleted ON notes(is_deleted);
CREATE INDEX IF NOT EXISTS idx_notes_title ON notes(title);
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
CREATE INDEX IF NOT EXISTS idx_search_history_time ON search_history(searched_at DESC);
```

---

## 4. Foreign Key Constraints & Cascading

- `PRAGMA foreign_keys = ON;` is executed on every database open connection.
- When a `note` is permanently deleted, all its entries in `note_tags` are automatically deleted via `ON DELETE CASCADE`.
- When a `tag` is deleted, its junction records in `note_tags` are automatically removed via `ON DELETE CASCADE`, leaving notes intact.
- When a `folder` is deleted with "Move to Unfiled", notes have their `folder_id` set to `NULL` via `ON DELETE SET NULL`.

---

## 5. Database Versioning & Migrations

- Current Version: `1`
- `onUpgrade` hook is implemented inside `DatabaseHelper`:
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Migration path template for future feature expansion
  }
}
```
