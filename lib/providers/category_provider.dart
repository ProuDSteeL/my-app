import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/category.dart';
import 'auth_provider.dart';

part 'category_provider.g.dart';

@riverpod
Future<List<Category>> categories(Ref ref) async {
  final client = ref.watch(supabaseProvider);
  final response = await client
      .from('categories')
      .select()
      .order('display_order');

  return (response as List)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList();
}
