# NoteVault — System Architecture & Design Specification

NoteVault is built using modern **Clean Architecture** combined with **Domain-Driven Design (DDD)** and the **Provider** reactive state management pattern.

---

## 1. Architectural Layers

```
lib/
├── core/                  # Enterprise foundations & cross-cutting utilities
│   ├── constants/         # App Colors, Dimensions, Strings
│   ├── extensions/        # String & Date formatting and analytics extensions
│   ├── theme/             # Material 3 light/dark theme specifications
│   └── utils/             # Debouncers, Validators, Result Monad
├── domain/                # Pure Business Logic (Framework Agnostic)
│   ├── entities/          # NoteEntity, FolderEntity, TagEntity
│   ├── repositories/      # NoteRepository, FolderRepository, TagRepository...
│   └── usecases/          # CreateNote, UpdateNote, SoftDeleteNote, RestoreBackup...
├── data/                  # Concrete Data Layer & Persistence
│   ├── datasources/local/ # DatabaseHelper, SQLite datasources
│   ├── models/            # NoteModel, FolderModel, TagModel, BackupModel
│   └── repositories/      # Repository implementations connecting to datasources
├── services/              # Device hardware & platform integrations
│   ├── database_service.dart
│   ├── preference_service.dart
│   ├── security_service.dart
│   ├── notification_service.dart
│   ├── export_service.dart
│   └── backup_service.dart
└── presentation/          # User Interface & View State
    ├── providers/         # NotesProvider, FoldersProvider, TagsProvider, SettingsProvider...
    ├── screens/           # 20+ specialized feature screens
    └── widgets/           # Atomic, reusable Material 3 components
```

---

## 2. Layer Responsibilities

### 2.1 Core Layer
- Contains zero application logic.
- Houses immutable constants (`AppColors`, `AppDimensions`, `AppStrings`), pure functional extensions (`wordCount`, `formatRelative`, `daysRemainingInTrash`), and the functional `Result<T>` monad for exception-free error propagation.

### 2.2 Domain Layer (Pure Dart)
- Contains the central business abstractions.
- Defines immutable domain entities (`NoteEntity`, `FolderEntity`, `TagEntity`) and abstract repository interfaces (`NoteRepository`, `FolderRepository`, etc.).
- Independent of UI frameworks, SQLite engines, or external packages.

### 2.3 Data Layer
- Responsible for data persistence, schema conversions, and serialization.
- `DatabaseHelper` manages SQLite lifecycle, foreign keys, database triggers, index optimizations, and version migrations.
- Models (`NoteModel`, `FolderModel`, `TagModel`) handle mapping between SQLite row dictionaries and Dart objects.
- Repository implementations implement domain repository contracts, mapping models into immutable entities.

### 2.4 Services Layer
- Encapsulates device-level APIs and platform channels:
  - `NotificationService`: Manages `flutter_local_notifications` initialization and timezone-aware reminder scheduling.
  - `SecurityService`: Handles `local_auth` biometric prompts, PIN verification, and SHA-256 password hashing.
  - `ExportService`: Assembles vector PDF layouts via `pdf` and `printing`.
  - `BackupService`: Manages file picking and JSON backup validation.
  - `PreferenceService`: Manages fast key-value persistence via `shared_preferences`.

### 2.5 Presentation Layer
- Built strictly according to Material 3 design standards.
- View models are encapsulated in `ChangeNotifier` providers (`NotesProvider`, `FoldersProvider`, `TagsProvider`, `SearchProvider`, `SettingsProvider`, `SecurityProvider`).
- Screens observe providers and re-render only when relevant domain state changes.
- Multi-selection, search debounce, and auto-save are handled reactively without blocking user interactions.

---

## 3. Data Flow & Reactive State Cycle

```
[User Action in UI]
        │
        ▼
[Presentation Screen / Widget]
        │ Calls method
        ▼
[ChangeNotifier Provider]
        │ Invokes
        ▼
[Domain Use Case / Repository]
        │ Calls
        ▼
[Local DataSource / SQLite Engine]
        │ Executes atomic SQL transaction
        ▼
[SQLite Storage (notevault.db)]
        │ Returns Raw Map
        ▼
[Data Models (fromMap)]
        │ Converts to
        ▼
[Domain Entities (toEntity)]
        │ Returns Result<T>
        ▼
[ChangeNotifier Provider Updates State]
        │ Calls notifyListeners()
        ▼
[UI Widgets Re-render with 60 FPS Smoothness]
```

---

## 4. Design Patterns Employed

1. **Repository Pattern**: Decouples data retrieval and database schema structures from UI and business logic.
2. **Result Monad Pattern**: Eliminates unhandled runtime exceptions by encapsulating outcomes in `Result.success(data)` or `Result.failure(message)`.
3. **Debouncer Pattern**: Controls high-frequency text-editing events to execute auto-save only after 800ms of user inactivity, reducing SQLite disk writes by over 90%.
4. **Observer Pattern**: State management powered by Provider's `ChangeNotifier` and `ListenableBuilder`.
5. **Dependency Injection**: Services and repositories are instantiated at app launch in `main.dart` and provided to the widget tree via `MultiProvider`.
