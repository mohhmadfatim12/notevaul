import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/archive/archive_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/folders/folder_list_screen.dart';
import 'presentation/screens/notes/notes_screen.dart';
import 'presentation/screens/notes/pinned_notes_screen.dart';
import 'presentation/screens/reminders/reminders_screen.dart';
import 'presentation/screens/security/pin_unlock_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/tags/tag_list_screen.dart';
import 'presentation/screens/trash/trash_screen.dart';

class NoteVaultApp extends StatelessWidget {
  const NoteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'NoteVault',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(accentColor: settings.accentColor),
          darkTheme: AppTheme.dark(accentColor: settings.accentColor),
          themeMode: settings.themeMode,
          home: const AppLifecycleWatcher(child: SplashScreen()),
        );
      },
    );
  }
}

class AppLifecycleWatcher extends StatefulWidget {
  final Widget child;

  const AppLifecycleWatcher({super.key, required this.child});

  @override
  State<AppLifecycleWatcher> createState() => _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends State<AppLifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final security = Provider.of<SecurityProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      security.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      security.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (ctx, security, _) {
        if (security.isLocked && security.isPinConfigured) {
          return PinUnlockScreen(
            onSuccess: security.unlock,
          );
        }
        return widget.child;
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to Notes tab

  final List<Widget> _screens = const [
    DashboardScreen(),
    NotesScreen(),
    FolderListScreen(),
    TagListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NoteVault',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Smart Offline Notes Organizer',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('All Notes'),
              selected: _currentIndex == 1,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: const Text('Folders'),
              selected: _currentIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tag_rounded),
              title: const Text('Tags'),
              selected: _currentIndex == 3,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.push_pin_rounded, color: AppColors.pinned),
              title: const Text('Pinned Notes'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PinnedNotesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded, color: AppColors.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm_rounded, color: AppColors.reminder),
              title: const Text('Reminders'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded, color: AppColors.archived),
              title: const Text('Archived'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.trash),
              title: const Text('Trash'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrashScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              selected: _currentIndex == 4,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Folders',
          ),
          NavigationDestination(
            icon: Icon(Icons.tag_outlined),
            selectedIcon: Icon(Icons.tag_rounded),
            label: 'Tags',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
