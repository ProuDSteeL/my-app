// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publishedBooks)
final publishedBooksProvider = PublishedBooksProvider._();

final class PublishedBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  PublishedBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishedBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishedBooksHash();

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    return publishedBooks(ref);
  }
}

String _$publishedBooksHash() => r'd3321fdef900ceb8b53ff4f80ac84c8b465c21cb';

@ProviderFor(newBooks)
final newBooksProvider = NewBooksProvider._();

final class NewBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  NewBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newBooksHash();

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    return newBooks(ref);
  }
}

String _$newBooksHash() => r'8330d828badf640f6d6b92448336291e81a37018';

@ProviderFor(bookById)
final bookByIdProvider = BookByIdFamily._();

final class BookByIdProvider
    extends $FunctionalProvider<AsyncValue<Book>, Book, FutureOr<Book>>
    with $FutureModifier<Book>, $FutureProvider<Book> {
  BookByIdProvider._({
    required BookByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookByIdHash();

  @override
  String toString() {
    return r'bookByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Book> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Book> create(Ref ref) {
    final argument = this.argument as String;
    return bookById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookByIdHash() => r'8821911730fda08d20b888cdce34e76eacef0d61';

final class BookByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Book>, String> {
  BookByIdFamily._()
    : super(
        retry: null,
        name: r'bookByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookByIdProvider call(String bookId) =>
      BookByIdProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookByIdProvider';
}

@ProviderFor(keyIdeasForBook)
final keyIdeasForBookProvider = KeyIdeasForBookFamily._();

final class KeyIdeasForBookProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<KeyIdea>>,
          List<KeyIdea>,
          FutureOr<List<KeyIdea>>
        >
    with $FutureModifier<List<KeyIdea>>, $FutureProvider<List<KeyIdea>> {
  KeyIdeasForBookProvider._({
    required KeyIdeasForBookFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'keyIdeasForBookProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$keyIdeasForBookHash();

  @override
  String toString() {
    return r'keyIdeasForBookProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<KeyIdea>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<KeyIdea>> create(Ref ref) {
    final argument = this.argument as String;
    return keyIdeasForBook(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is KeyIdeasForBookProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$keyIdeasForBookHash() => r'9ed1acd919c8cecf80dbf39698195be84f555250';

final class KeyIdeasForBookFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<KeyIdea>>, String> {
  KeyIdeasForBookFamily._()
    : super(
        retry: null,
        name: r'keyIdeasForBookProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  KeyIdeasForBookProvider call(String bookId) =>
      KeyIdeasForBookProvider._(argument: bookId, from: this);

  @override
  String toString() => r'keyIdeasForBookProvider';
}

@ProviderFor(booksByCategory)
final booksByCategoryProvider = BooksByCategoryFamily._();

final class BooksByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  BooksByCategoryProvider._({
    required BooksByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'booksByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$booksByCategoryHash();

  @override
  String toString() {
    return r'booksByCategoryProvider'
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
    return booksByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BooksByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$booksByCategoryHash() => r'9c412cbf0e69aaaf9de17689caa923c70801ec6c';

final class BooksByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Book>>, String> {
  BooksByCategoryFamily._()
    : super(
        retry: null,
        name: r'booksByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BooksByCategoryProvider call(String categoryId) =>
      BooksByCategoryProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'booksByCategoryProvider';
}

@ProviderFor(similarBooks)
final similarBooksProvider = SimilarBooksFamily._();

final class SimilarBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  SimilarBooksProvider._({
    required SimilarBooksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'similarBooksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$similarBooksHash();

  @override
  String toString() {
    return r'similarBooksProvider'
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
    return similarBooks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SimilarBooksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$similarBooksHash() => r'5bb355e5c0155aff98fdf5934ddc579874733e34';

final class SimilarBooksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Book>>, String> {
  SimilarBooksFamily._()
    : super(
        retry: null,
        name: r'similarBooksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SimilarBooksProvider call(String bookId) =>
      SimilarBooksProvider._(argument: bookId, from: this);

  @override
  String toString() => r'similarBooksProvider';
}
