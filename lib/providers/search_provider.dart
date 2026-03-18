import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/app_constants.dart';
import '../core/storage/hive_keys.dart';
import '../domain/entities/book.dart';
import 'auth_provider.dart';

part 'search_provider.g.dart';

const _searchHistoryKey = 'search_history';

@riverpod
Future<List<Book>> searchBooks(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];

  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('books')
      .select()
      .eq('status', 'published')
      .or('title.ilike.%$query%,author.ilike.%$query%')
      .order('created_at', ascending: false)
      .limit(AppConstants.catalogPageSize);

  return (response as List)
      .map((e) => Book.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
class SearchHistory extends _$SearchHistory {
  @override
  List<String> build() {
    final box = Hive.box<dynamic>(HiveKeys.userPrefsBox);
    final stored = box.get(_searchHistoryKey) as List<dynamic>?;
    return stored?.cast<String>() ?? [];
  }

  void addQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.where((q) => q != trimmed),
    ].take(AppConstants.maxSearchHistory).toList();

    state = updated;
    Hive.box<dynamic>(HiveKeys.userPrefsBox)
        .put(_searchHistoryKey, updated);
  }

  void removeQuery(String query) {
    state = state.where((q) => q != query).toList();
    Hive.box<dynamic>(HiveKeys.userPrefsBox)
        .put(_searchHistoryKey, state);
  }

  void clear() {
    state = [];
    Hive.box<dynamic>(HiveKeys.userPrefsBox).delete(_searchHistoryKey);
  }
}
