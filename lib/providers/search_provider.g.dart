// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchBooks)
final searchBooksProvider = SearchBooksFamily._();

final class SearchBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  SearchBooksProvider._({
    required SearchBooksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchBooksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchBooksHash();

  @override
  String toString() {
    return r'searchBooksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    final argument = this.argument as String;
    return searchBooks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchBooksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchBooksHash() => r'4b1338c6758e31b44edff3cd1feb1f6634593230';

final class SearchBooksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Book>>, String> {
  SearchBooksFamily._()
    : super(
        retry: null,
        name: r'searchBooksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchBooksProvider call(String query) =>
      SearchBooksProvider._(argument: query, from: this);

  @override
  String toString() => r'searchBooksProvider';
}

@ProviderFor(SearchHistory)
final searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends $NotifierProvider<SearchHistory, List<String>> {
  SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  SearchHistory create() => SearchHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$searchHistoryHash() => r'bb380735fc2a479458eb93caa0cd3ae70b477f87';

abstract class _$SearchHistory extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
