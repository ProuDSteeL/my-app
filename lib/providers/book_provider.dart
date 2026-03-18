import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/book.dart';
import '../domain/entities/key_idea.dart';
import 'auth_provider.dart';

part 'book_provider.g.dart';

@riverpod
Future<List<Book>> publishedBooks(Ref ref) async {
  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('books')
      .select()
      .eq('status', 'published')
      .order('created_at', ascending: false);

  return (response as List).map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
}

@riverpod
Future<List<Book>> newBooks(Ref ref) async {
  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('books')
      .select()
      .eq('status', 'published')
      .order('created_at', ascending: false)
      .limit(10);

  return (response as List).map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
}

@riverpod
Future<Book> bookById(Ref ref, String bookId) async {
  final client = ref.watch(supabaseProvider);
  final response =
      await client.from('books').select().eq('id', bookId).single();

  return Book.fromJson(response);
}

@riverpod
Future<List<KeyIdea>> keyIdeasForBook(Ref ref, String bookId) async {
  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('key_ideas')
      .select()
      .eq('book_id', bookId)
      .order('display_order');

  return (response as List)
      .map((e) => KeyIdea.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<Book>> booksByCategory(Ref ref, String categoryId) async {
  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('book_categories')
      .select('book_id, books(*)')
      .eq('category_id', categoryId);

  return (response as List)
      .where((e) =>
          e['books'] != null &&
          (e['books'] as Map<String, dynamic>)['status'] == 'published')
      .map((e) => Book.fromJson(e['books'] as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<Book>> similarBooks(Ref ref, String bookId) async {
  final book = await ref.watch(bookByIdProvider(bookId).future);
  final client = ref.watch(supabaseProvider);

  // Get books that share at least one tag
  final response = await client
      .from('books')
      .select()
      .eq('status', 'published')
      .neq('id', bookId)
      .limit(5);

  final books = (response as List)
      .map((e) => Book.fromJson(e as Map<String, dynamic>))
      .toList();

  // Sort by tag overlap
  books.sort((a, b) {
    final overlapA =
        a.tags.where((t) => book.tags.contains(t)).length;
    final overlapB =
        b.tags.where((t) => book.tags.contains(t)).length;
    return overlapB.compareTo(overlapA);
  });

  return books;
}
