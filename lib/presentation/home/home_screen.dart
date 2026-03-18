import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/category.dart';
import '../../presentation/common/animated_book_list.dart';
import '../../presentation/common/book_card.dart';
import '../../presentation/common/book_card_skeleton.dart';
import '../../presentation/common/section_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/category_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final displayName =
        user?.userMetadata?['display_name'] as String? ?? '';
    final greeting = displayName.isNotEmpty
        ? '${_greeting()}, $displayName'
        : _greeting();

    final categoriesAsync = ref.watch(categoriesProvider);
    final newBooksAsync = ref.watch(newBooksProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(newBooksProvider);
            ref.invalidate(categoriesProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    greeting,
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
              ),

              // Categories row
              categoriesAsync.when(
                data: (categories) => SliverToBoxAdapter(
                  child: _CategoriesRow(categories: categories),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
              ),

              // New books section
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Новинки'),
              ),
              newBooksAsync.when(
                data: (books) => SliverToBoxAdapter(
                  child: _HorizontalBookList(books: books),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: _HorizontalSkeletonList(),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Ошибка загрузки',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),

              // Per-category rows
              categoriesAsync.when(
                data: (categories) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CategoryBookRow(
                      category: categories[index],
                    ),
                    childCount: categories.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
              ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return ActionChip(
            label: Text(cat.name),
            labelStyle: theme.textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onPressed: () => context.go('/search?category=${cat.slug}'),
          );
        },
      ),
    );
  }
}

class _HorizontalBookList extends StatelessWidget {
  const _HorizontalBookList({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return AnimatedListItem(
            index: index,
            child: SizedBox(
              width: 150,
              child: BookCard(
                title: book.title,
                author: book.author,
                coverUrl: book.coverUrl,
                readTimeMinutes: book.readTimeMinutes,
                onTap: () => context.push('/book/${book.id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalSkeletonList extends StatelessWidget {
  const _HorizontalSkeletonList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => const SizedBox(
          width: 150,
          child: BookCardSkeleton(),
        ),
      ),
    );
  }
}

class _CategoryBookRow extends ConsumerWidget {
  const _CategoryBookRow({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksByCategoryProvider(category.id));

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: category.name),
            _HorizontalBookList(books: books),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
