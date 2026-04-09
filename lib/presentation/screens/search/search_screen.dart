import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/presentation/providers/folders_provider.dart';
import 'package:notevault/presentation/providers/search_provider.dart';
import 'package:notevault/presentation/providers/tags_provider.dart';
import 'package:notevault/presentation/screens/notes/note_details_screen.dart';
import 'package:notevault/presentation/widgets/color_picker_row.dart';
import 'package:notevault/presentation/widgets/empty_state.dart';
import 'package:notevault/presentation/widgets/loading_indicator.dart';
import 'package:notevault/presentation/widgets/note_card.dart';
import 'package:notevault/presentation/widgets/search_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final folders = Provider.of<FoldersProvider>(context, listen: false).folders;
    final tags = Provider.of<TagsProvider>(context, listen: false).tags;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final theme = Theme.of(ctx);

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.p20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            searchProvider.clearFilters();
                            setModalState(() {});
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status Filters
                    Text('Status', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Pinned'),
                          selected: searchProvider.filterPinned == true,
                          onSelected: (val) {
                            searchProvider.setStatusFilter(
                              pinned: val ? true : null,
                              favorite: searchProvider.filterFavorite,
                              archived: searchProvider.filterArchived,
                              trash: searchProvider.filterTrash,
                            );
                            setModalState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Favorite'),
                          selected: searchProvider.filterFavorite == true,
                          onSelected: (val) {
                            searchProvider.setStatusFilter(
                              pinned: searchProvider.filterPinned,
                              favorite: val ? true : null,
                              archived: searchProvider.filterArchived,
                              trash: searchProvider.filterTrash,
                            );
                            setModalState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Archived'),
                          selected: searchProvider.filterArchived == true,
                          onSelected: (val) {
                            searchProvider.setStatusFilter(
                              pinned: searchProvider.filterPinned,
                              favorite: searchProvider.filterFavorite,
                              archived: val ? true : null,
                              trash: searchProvider.filterTrash,
                            );
                            setModalState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Trash'),
                          selected: searchProvider.filterTrash == true,
                          onSelected: (val) {
                            searchProvider.setStatusFilter(
                              pinned: searchProvider.filterPinned,
                              favorite: searchProvider.filterFavorite,
                              archived: searchProvider.filterArchived,
                              trash: val ? true : null,
                            );
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Folders Filter
                    if (folders.isNotEmpty) ...[
                      Text('Folders', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: folders.map((f) {
                          final isSelected = searchProvider.filterFolderId == f.id;
                          return FilterChip(
                            label: Text(f.name),
                            selected: isSelected,
                            onSelected: (val) {
                              searchProvider.setFolderFilter(val ? f.id : null);
                              setModalState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tags Filter
                    if (tags.isNotEmpty) ...[
                      Text('Tags', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: tags.map((t) {
                          final isSelected = searchProvider.filterTagId == t.id;
                          return FilterChip(
                            label: Text('#${t.name}'),
                            selected: isSelected,
                            onSelected: (val) {
                              searchProvider.setTagFilter(val ? t.id : null);
                              setModalState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Color Filter
                    Text('Note Color', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ColorPickerRow(
                      selectedColorId: searchProvider.filterColor ?? 0,
                      onColorSelected: (id) {
                        searchProvider.setColorFilter(id == 0 ? null : id);
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openDetails(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Vault'),
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            onChanged: searchProvider.onQueryChanged,
            onClear: () {
              searchProvider.onQueryChanged('');
            },
            onFilterTap: () => _showFilterModal(context),
            hasActiveFilters: searchProvider.hasActiveFilters,
          ),

          // Active filter chip reminder
          if (searchProvider.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  const Text('Filters Active', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: searchProvider.clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),

          // Body: Recent searches or results
          Expanded(
            child: searchProvider.isLoading
                ? const LoadingIndicator(message: 'Searching notes...')
                : _searchController.text.trim().isEmpty && !searchProvider.hasActiveFilters
                    ? _buildRecentSearches(searchProvider)
                    : searchProvider.results.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Matching Notes',
                            subtitle:
                                'Try checking for typos or searching by tag or folder name.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: searchProvider.results.length,
                            itemBuilder: (ctx, index) {
                              final note = searchProvider.results[index];
                              return NoteCard(
                                note: note,
                                onTap: () => _openDetails(note),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(SearchProvider searchProvider) {
    final recent = searchProvider.recentSearches;
    if (recent.isEmpty) {
      return const EmptyState(
        icon: Icons.manage_search_rounded,
        title: 'Search Anything',
        subtitle: 'Search across titles, bodies, notebooks, and tags.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: searchProvider.clearRecentSearches,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((item) {
              return InputChip(
                label: Text(item.query),
                avatar: const Icon(Icons.history_rounded, size: 16),
                onPressed: () {
                  _searchController.text = item.query;
                  searchProvider.onQueryChanged(item.query);
                },
                onDeleted: () => searchProvider.deleteRecentSearch(item.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
