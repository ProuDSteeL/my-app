import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/book.dart';
import '../../presentation/common/animated_book_list.dart';
import '../../presentation/common/app_chip.dart';
import '../../presentation/common/book_card.dart';
import '../../presentation/common/book_card_skeleton.dart';
import '../../providers/book_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/search_provider.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Update suffixIcon visibility
    setState(() {});
    _debounce?.cancel();
    final value = _searchController.text;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
      if (value.trim().isNotEmpty) {
        ref.read(searchHistoryProvider.notifier).addQuery(value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final searchHistory = ref.watch(searchHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: false,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Поиск по названию или автору',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                            _focusNode.requestFocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Category chips
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return AppChip(
                        label: 'Все',
                        isSelected: _selectedCategory == null,
                        onTap: () =>
                            setState(() => _selectedCategory = null),
                      );
                    }
                    final cat = categories[index - 1];
                    return AppChip(
                      label: cat.name,
                      isSelected: _selectedCategory == cat.id,
                      onTap: () => setState(
                        () => _selectedCategory =
                            _selectedCategory == cat.id
                                ? null
                                : cat.id,
                      ),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 40),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Content
            Expanded(
              child: _query.isNotEmpty
                  ? _SearchResults(
                      query: _query,
                      categoryFilter: _selectedCategory,
                    )
                  : _query.isEmpty && _searchController.text.isEmpty
                      ? searchHistory.isNotEmpty
                          ? _SearchHistoryList(
                              history: searchHistory,
                              onSelect: (q) {
                                _searchController.text = q;
                                setState(() => _query = q);
                              },
                              onClear: () => ref
                                  .read(searchHistoryProvider.notifier)
                                  .clear(),
                            )
                          : _AllBooks(
                              categoryFilter: _selectedCategory,
                            )
                      : _AllBooks(
                          categoryFilter: _selectedCategory,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    this.categoryFilter,
  });

  final String query;
  final String? categoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchBooksProvider(query));

    return resultsAsync.when(
      data: (books) {
        final filtered = categoryFilter != null
            ? books
            : books;
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'Ничего не найдено',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return _BookGrid(books: filtered);
      },
      loading: () => const _SkeletonGrid(),
      error: (error, _) => Center(
        child: Text(
          'Ошибка поиска',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _AllBooks extends ConsumerWidget {
  const _AllBooks({this.categoryFilter});

  final String? categoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categoryFilter != null) {
      final booksAsync =
          ref.watch(booksByCategoryProvider(categoryFilter!));
      return booksAsync.when(
        data: (books) => _BookGrid(books: books),
        loading: () => const _SkeletonGrid(),
        error: (_, __) => const Center(child: Text('Ошибка загрузки')),
      );
    }

    final booksAsync = ref.watch(publishedBooksProvider);
    return booksAsync.when(
      data: (books) => _BookGrid(books: books),
      loading: () => const _SkeletonGrid(),
      error: (_, __) => const Center(child: Text('Ошибка загрузки')),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return AnimatedListItem(
          index: index,
          child: BookCard(
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl,
            readTimeMinutes: book.readTimeMinutes,
            onTap: () => context.push('/book/${book.id}'),
          ),
        );
      },
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const BookCardSkeleton(),
    );
  }
}

class _SearchHistoryList extends StatelessWidget {
  const _SearchHistoryList({
    required this.history,
    required this.onSelect,
    required this.onClear,
  });

  final List<String> history;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('История поиска',
                  style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: onClear,
                child: const Text('Очистить'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(history[index]),
                onTap: () => onSelect(history[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
