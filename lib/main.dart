import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/folder_local_datasource.dart';
import 'data/datasources/local/note_local_datasource.dart';
import 'data/datasources/local/search_history_datasource.dart';
import 'data/datasources/local/tag_local_datasource.dart';
import 'data/repositories/backup_repository_impl.dart';
import 'data/repositories/folder_repository_impl.dart';
import 'data/repositories/note_repository_impl.dart';
import 'data/repositories/search_repository_impl.dart';
import 'data/repositories/tag_repository_impl.dart';
import 'domain/repositories/backup_repository.dart';
import 'domain/repositories/folder_repository.dart';
import 'domain/repositories/note_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/repositories/tag_repository.dart';
import 'presentation/providers/folders_provider.dart';
import 'presentation/providers/notes_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/tags_provider.dart';
import 'services/backup_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/preference_service.dart';
import 'services/security_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final preferenceService = PreferenceService(prefs);

  // Initialize Core Services
  final securityService = SecurityService(preferenceService);
  final notificationService = NotificationService.instance;
  await notificationService.initialize();

  // Initialize Database Helper & Data Sources
  final dbHelper = DatabaseHelper.instance;
  final databaseService = DatabaseService(helper: dbHelper);

  final folderDataSource = FolderLocalDataSourceImpl(helper: dbHelper);
  final tagDataSource = TagLocalDataSourceImpl(helper: dbHelper);
  final noteDataSource = NoteLocalDataSourceImpl(helper: dbHelper);
  final searchDataSource = SearchHistoryDataSourceImpl(helper: dbHelper);

  // Initialize Repositories
  final folderRepository = FolderRepositoryImpl(dataSource: folderDataSource);
  final tagRepository = TagRepositoryImpl(dataSource: tagDataSource);
  final searchRepository = SearchRepositoryImpl(dataSource: searchDataSource);
  final backupRepository = BackupRepositoryImpl(helper: dbHelper);
  final noteRepository = NoteRepositoryImpl(
    noteSource: noteDataSource,
    tagSource: tagDataSource,
    folderSource: folderDataSource,
    helper: dbHelper,
  );

  final backupService = BackupService(backupRepository);

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<PreferenceService>.value(value: preferenceService),
        Provider<SecurityService>.value(value: securityService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<BackupService>.value(value: backupService),
        Provider<NotificationService>.value(value: notificationService),

        // Domain Repositories
        Provider<FolderRepository>.value(value: folderRepository),
        Provider<TagRepository>.value(value: tagRepository),
        Provider<SearchRepository>.value(value: searchRepository),
        Provider<BackupRepository>.value(value: backupRepository),
        Provider<NoteRepository>.value(value: noteRepository),

        // State Providers
        ChangeNotifierProvider(create: (_) => SettingsProvider(preferenceService)),
        ChangeNotifierProvider(create: (_) => SecurityProvider(securityService)),
        ChangeNotifierProvider(create: (_) => FoldersProvider(folderRepository)),
        ChangeNotifierProvider(create: (_) => TagsProvider(tagRepository)),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(noteRepository, notificationService: notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(noteRepository, searchRepository),
        ),
      ],
      child: const NoteVaultApp(),
    ),
  );
}
