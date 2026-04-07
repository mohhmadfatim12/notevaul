import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/notes_provider.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'package:notevault/presentation/widgets/note_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).loadFavoriteNotes();
    });
  }

  void _openDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final favorites = notesProvider.favoriteNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Notes'),
      ),
      body: notesProvider.isLoading
          ? const LoadingIndicator(message: 'Loading favorites...')
          : favorites.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No Favorites Yet',
                  subtitle:
                      'Tap the heart icon on any note to mark it as favorite for fast access.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: favorites.length,
                  itemBuilder: (ctx, index) {
                    final note = favorites[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _openDetails(note),
                      onFavoriteToggle: () => notesProvider.toggleFavorite(note),
                    );
                  },
                ),
    );
  }
}
