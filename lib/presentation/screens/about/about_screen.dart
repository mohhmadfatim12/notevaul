import 'package:flutter/material.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NoteVault'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.p24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppStrings.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Features Breakdown Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Built For Privacy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'NoteVault is built entirely around privacy-first offline computing. All user data, notes, notebooks, and tags are stored strictly in a local SQLite database on your device.',
                    style: TextStyle(height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Zero internet connection required\n'
                    '• No tracking, telemetry, or analytics\n'
                    '• Local biometric authentication\n'
                    '• Hardware-accelerated 60 FPS UI',
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Open Source Licenses button
          Card(
            child: ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Open Source Licenses'),
              subtitle: const Text('View software licenses for included components'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: AppStrings.appName,
                  applicationVersion: AppStrings.appVersion,
                  applicationLegalese: 'Copyright © 2026. All rights reserved.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
