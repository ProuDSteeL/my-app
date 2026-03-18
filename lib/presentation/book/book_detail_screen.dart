import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/key_idea.dart';
import '../../presentation/common/app_chip.dart';
import '../../presentation/common/book_card.dart';
import '../../providers/book_provider.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookByIdProvider(bookId));

    return bookAsync.when(
      data: (book) => _BookDetailContent(book: book),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ошибка загрузки книги')),
      ),
    );
  }
}

class _BookDetailContent extends ConsumerWidget {
  const _BookDetailContent({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final keyIdeasAsync =
        ref.watch(keyIdeasForBookProvider(book.id));
    final similarAsync = ref.watch(similarBooksProvider(book.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with back button
          SliverAppBar(
            pinned: true,
            title: Text(
              book.title,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover + meta row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 120,
                          height: 180,
                          child: book.coverUrl != null
                              ? Image.network(
                                  book.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _CoverPlaceholder(theme: theme),
                                )
                              : _CoverPlaceholder(theme: theme),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Meta info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style:
                                  theme.textTheme.bodyLarge?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: theme
                                      .colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${book.readTimeMinutes} мин',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tags
                  if (book.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: book.tags
                          .map((tag) => AppChip(label: tag))
                          .toList(),
                    ),
                  ],

                  // Description
                  if (book.description != null) ...[
                    const SizedBox(height: 24),
                    Text('О книге',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      book.description!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],

                  // Why read
                  if (book.whyRead != null) ...[
                    const SizedBox(height: 24),
                    Text('Зачем читать?',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      book.whyRead!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],

                  // About author
                  if (book.aboutAuthor != null) ...[
                    const SizedBox(height: 24),
                    Text('Об авторе',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      book.aboutAuthor!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Key Ideas carousel
          keyIdeasAsync.when(
            data: (ideas) {
              if (ideas.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
              return SliverToBoxAdapter(
                child: _KeyIdeasCarousel(ideas: ideas, theme: theme),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
          ),

          // Similar books
          similarAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                );
              }
              return SliverToBoxAdapter(
                child: _SimilarBooks(books: books, theme: theme),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.book_outlined,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _KeyIdeasCarousel extends StatelessWidget {
  const _KeyIdeasCarousel({
    required this.ideas,
    required this.theme,
  });

  final List<KeyIdea> ideas;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Ключевые идеи',
              style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ideas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      idea.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        idea.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarBooks extends StatelessWidget {
  const _SimilarBooks({
    required this.books,
    required this.theme,
  });

  final List<Book> books;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Похожие книги',
              style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              return SizedBox(
                width: 150,
                child: BookCard(
                  title: book.title,
                  author: book.author,
                  coverUrl: book.coverUrl,
                  readTimeMinutes: book.readTimeMinutes,
                  onTap: () => context.push('/book/${book.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
