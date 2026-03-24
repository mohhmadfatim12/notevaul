/// Centralized string constants for NoteVault.
class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'NoteVault';
  static const String appTagline = 'Organize your thoughts, tasks, and ideas.';
  static const String appVersion = '1.0.0';

  // Navigation & Sections
  static const String navNotes = 'Notes';
  static const String navFolders = 'Folders';
  static const String navTags = 'Tags';
  static const String navSearch = 'Search';
  static const String navDashboard = 'Dashboard';
  static const String navSettings = 'Settings';
  static const String navReminders = 'Reminders';
  static const String navFavorites = 'Favorites';
  static const String navArchive = 'Archive';
  static const String navTrash = 'Trash';

  // Note Actions
  static const String newNote = 'New Note';
  static const String editNote = 'Edit Note';
  static const String noteTitleHint = 'Title';
  static const String noteBodyHint = 'Write your thoughts, checklist, or ideas...';
  static const String saved = 'Saved';
  static const String saving = 'Saving...';
  static const String pinNote = 'Pin';
  static const String unpinNote = 'Unpin';
  static const String favoriteNote = 'Favorite';
  static const String unfavoriteNote = 'Unfavorite';
  static const String archiveNote = 'Archive';
  static const String unarchiveNote = 'Unarchive';
  static const String moveToTrash = 'Move to Trash';
  static const String restoreNote = 'Restore';
  static const String deletePermanently = 'Delete Permanently';

  // Folders & Tags
  static const String folders = 'Folders';
  static const String newFolder = 'New Folder';
  static const String editFolder = 'Edit Folder';
  static const String folderNameHint = 'Folder name';
  static const String unfiled = 'Unfiled';
  static const String tags = 'Tags';
  static const String newTag = 'New Tag';
  static const String editTag = 'Edit Tag';
  static const String tagNameHint = 'Tag name';

  // Search & Filters
  static const String searchNotesHint = 'Search notes, folders, tags...';
  static const String recentSearches = 'Recent Searches';
  static const String clearRecent = 'Clear Recent';
  static const String noResultsFound = 'No notes found matching your search';

  // Trash
  static const String emptyTrash = 'Empty Trash';
  static const String trashNotice =
      'Items in Trash are automatically deleted after 30 days.';

  // Export & Backup
  static const String exportPdf = 'Export as PDF';
  static const String exportTxt = 'Export as TXT';
  static const String shareNote = 'Share Note';
  static const String backupData = 'Create Local Backup';
  static const String restoreData = 'Restore From Backup';

  // Security
  static const String appLock = 'App Lock';
  static const String enterPin = 'Enter NoteVault PIN';
  static const String createPin = 'Create App PIN';
  static const String confirmPin = 'Confirm App PIN';
  static const String changePin = 'Change PIN';
  static const String disablePin = 'Disable PIN';
  static const String unlockWithBiometrics = 'Unlock with Biometrics';
  static const String biometricReason = 'Scan your fingerprint or face to open NoteVault';
}
