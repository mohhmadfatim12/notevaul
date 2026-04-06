import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/extensions/date_extensions.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/backup/backup_screen.dart';
import 'package:notevault/presentation/screens/folders/create_edit_folder_dialog.dart';
import 'package:notevault/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/screens/search/search_screen.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadDashboardStats();
    });
  }

  void _createNewNote() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
  }

  Future<void> _createNewFolder() async {
    await CreateEditFolderDialog.show(context);
    if (mounted) {
      Provider.of<NotesProvider>(context, listen: false).loadAll();
    }
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _openBackup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BackupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final stats = notesProvider.dashboardStats;

    if (stats == null) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Compiling analytics...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: notesProvider.loadDashboardStats,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.p16),
          children: [
            // Quick Actions Bar
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.p12),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.note_add_rounded,
                  label: 'New Note',
                  color: AppColors.primary,
                  onTap: _createNewNote,
                ),
                const SizedBox(width: AppDimensions.p8),
                _buildQuickAction(
                  context,
                  icon: Icons.create_new_folder_rounded,
                  label: 'New Folder',
                  color: AppColors.secondary,
                  onTap: _createNewFolder,
                ),
                const SizedBox(width: AppDimensions.p8),
                _buildQuickAction(
                  context,
                  icon: Icons.search_rounded,
                  label: 'Search',
                  color: AppColors.info,
                  onTap: _openSearch,
                ),
                const SizedBox(width: AppDimensions.p8),
                _buildQuickAction(
                  context,
                  icon: Icons.backup_rounded,
                  label: 'Backup',
                  color: AppColors.reminder,
                  onTap: _openBackup,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.p24),

            // Metrics Grid (2x4)
            Text(
              'Vault Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.p12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.85,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Notes',
                  value: stats.totalNotes.toString(),
                  icon: Icons.description_rounded,
                  color: AppColors.primary,
                ),
                _buildStatCard(
                  context,
                  title: 'Folders',
                  value: stats.totalFolders.toString(),
                  icon: Icons.folder_rounded,
                  color: AppColors.secondary,
                ),
                _buildStatCard(
                  context,
                  title: 'Tags',
                  value: stats.totalTags.toString(),
                  icon: Icons.tag_rounded,
                  color: AppColors.info,
                ),
                _buildStatCard(
                  context,
                  title: 'Pinned',
                  value: stats.totalPinned.toString(),
                  icon: Icons.push_pin_rounded,
                  color: AppColors.pinned,
                ),
                _buildStatCard(
                  context,
                  title: 'Favorites',
                  value: stats.totalFavorites.toString(),
                  icon: Icons.favorite_rounded,
                  color: AppColors.favorite,
                ),
                _buildStatCard(
                  context,
                  title: 'Archived',
                  value: stats.totalArchived.toString(),
                  icon: Icons.archive_rounded,
                  color: AppColors.archived,
                ),
                _buildStatCard(
                  context,
                  title: 'In Trash',
                  value: stats.totalTrash.toString(),
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.trash,
                ),
                _buildStatCard(
                  context,
                  title: 'Created This Week',
                  value: stats.createdThisWeek.toString(),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.p24),

            // Weekly Notes Activity Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Activity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${stats.updatedThisWeek} updates',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _calculateMaxY(stats.weeklyActivityByDay),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  final idx = val.toInt() - 1;
                                  if (idx >= 0 && idx < days.length) {
                                    return Text(days[idx],
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (idx) {
                            final day = idx + 1;
                            final count = stats.weeklyActivityByDay[day] ?? 0;
                            return BarChartGroupData(
                              x: day,
                              barRods: [
                                BarChartRodData(
                                  toY: count.toDouble(),
                                  color: theme.colorScheme.primary,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.p24),

            // Upcoming Reminders preview
            if (stats.upcomingReminders.isNotEmpty) ...[
              Text(
                'Upcoming Reminders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.p12),
              ...stats.upcomingReminders.map((note) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NoteDetailsScreen(note: note),
                          ),
                        );
                      },
                      leading: const Icon(Icons.alarm_rounded, color: AppColors.reminder),
                      title: Text(note.title.isNotEmpty ? note.title : 'Untitled Note'),
                      subtitle: Text(note.reminderAt!.formatRelative()),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ),
                  )),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(Map<int, int> activity) {
    int max = 5;
    for (final val in activity.values) {
      if (val > max) max = val;
    }
    return (max + 2).toDouble();
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.r16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.r16),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.p12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
