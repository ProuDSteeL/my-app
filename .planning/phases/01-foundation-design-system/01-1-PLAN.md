---
phase: 1
plan: 1
name: project-scaffold-and-dependencies
wave: 1
depends_on: []
requirements: [DSGN-01, DSGN-06]
files_modified:
  - pubspec.yaml
  - lib/main.dart
  - lib/app.dart
  - web/index.html
  - web/manifest.json
  - analysis_options.yaml
  - lib/core/constants/app_constants.dart
  - lib/core/constants/supabase_constants.dart
  - lib/core/constants/ui_constants.dart
  - lib/core/error/failures.dart
  - lib/core/storage/hive_init.dart
  - lib/core/storage/hive_keys.dart
  - .env.example
  - assets/fonts/PlayfairDisplay-SemiBold-subset.woff2
  - assets/fonts/PlayfairDisplay-Bold-subset.woff2
  - assets/fonts/SourceSans3-Regular-subset.woff2
  - assets/fonts/SourceSans3-SemiBold-subset.woff2
  - lib/core/theme/deferred_fonts.dart
autonomous: true
---

# Plan 01-1: Project Scaffold and Dependencies

## Objective
Create the Flutter Web/PWA project, install all Phase 1 dependencies, configure CanvasKit renderer, set up PWA manifest, initialize Hive CE and Supabase, and establish the project directory structure with core infrastructure files.

## Tasks

<task id="1">
<title>Create Flutter Web project and install core dependencies</title>
<read_first>
- /root/my-app/.planning/research/STACK.md (validated package versions)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md (project creation commands)
</read_first>
<action>
Run `flutter create --platforms web --project-name book_summary .` in `/root/my-app`.

Then add core dependencies to pubspec.yaml:
```
flutter pub add flutter_riverpod
flutter pub add riverpod_annotation
flutter pub add go_router
flutter pub add supabase_flutter
flutter pub add hive_ce_flutter
flutter pub add hive_ce
flutter pub add google_fonts
flutter pub add shimmer
flutter pub add phosphor_flutter
flutter pub add shared_preferences
flutter pub add flutter_animate
flutter pub add uuid
flutter pub add intl
flutter pub add json_annotation
flutter pub add freezed_annotation
flutter pub add connectivity_plus
flutter pub add animations
```

Dev dependencies:
```
flutter pub add --dev riverpod_generator
flutter pub add --dev build_runner
flutter pub add --dev json_serializable
flutter pub add --dev hive_ce_generator
flutter pub add --dev freezed
flutter pub add --dev very_good_analysis
```

Set the SDK constraints in pubspec.yaml:
- environment.sdk: ">=3.11.0 <4.0.0"
- environment.flutter: ">=3.41.0"

Set `flutter.uses-material-design: true` in pubspec.yaml.

Add font asset declarations to pubspec.yaml under `flutter.fonts`:
- family: PlayfairDisplay with weights 600 and 700
- family: SourceSans3 with weights 400 and 600

Add `assets/fonts/` to the flutter assets section.
</action>
<acceptance_criteria>
- pubspec.yaml contains `name: book_summary`
- pubspec.yaml contains `flutter_riverpod:` as a dependency
- pubspec.yaml contains `go_router:` as a dependency
- pubspec.yaml contains `supabase_flutter:` as a dependency
- pubspec.yaml contains `hive_ce_flutter:` as a dependency
- pubspec.yaml contains `google_fonts:` as a dependency
- pubspec.yaml contains `shimmer:` as a dependency
- pubspec.yaml contains `phosphor_flutter:` as a dependency
- pubspec.yaml contains `flutter_animate:` as a dependency
- pubspec.yaml contains `freezed_annotation:` as a dependency
- pubspec.yaml contains `connectivity_plus:` as a dependency
- pubspec.yaml contains `animations:` as a dependency
- pubspec.yaml contains `build_runner:` under dev_dependencies
- pubspec.yaml contains `riverpod_generator:` under dev_dependencies
- pubspec.yaml contains `freezed:` under dev_dependencies
- pubspec.yaml contains `hive_ce_generator:` under dev_dependencies
- pubspec.yaml contains `very_good_analysis:` under dev_dependencies
- `flutter pub get` exits with code 0
- web/ directory exists with index.html
</acceptance_criteria>
</task>

<task id="2">
<title>Configure web/index.html with CanvasKit renderer</title>
<read_first>
- /root/my-app/web/index.html (current state after flutter create)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §1 (CanvasKit config)
</read_first>
<action>
Replace web/index.html with the following content that forces CanvasKit renderer:

```html
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#C05621">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="manifest" href="manifest.json">
  <title>BookSummary</title>
</head>
<body>
  <script>
    {{flutter_js}}
    {{flutter_build_config}}

    _flutter.loader.load({
      config: {
        renderer: 'canvaskit',
        canvasKitVariant: 'auto',
      },
      onEntrypointLoaded: async function(engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine();
        await appRunner.runApp();
      }
    });
  </script>
</body>
</html>
```

Key elements:
- `lang="ru"` on the html tag
- theme-color meta tag set to `#C05621`
- apple-mobile-web-app-capable and status-bar-style meta tags
- `renderer: 'canvaskit'` in the Flutter loader config
- `canvasKitVariant: 'auto'`
</action>
<acceptance_criteria>
- web/index.html contains `lang="ru"`
- web/index.html contains `content="#C05621"` (theme-color)
- web/index.html contains `renderer: 'canvaskit'`
- web/index.html contains `canvasKitVariant: 'auto'`
- web/index.html contains `apple-mobile-web-app-capable`
</acceptance_criteria>
</task>

<task id="3">
<title>Create PWA manifest.json</title>
<read_first>
- /root/my-app/web/manifest.json (current state)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §1 (PWA manifest)
</read_first>
<action>
Replace web/manifest.json with:

```json
{
  "name": "BookSummary — Саммари книг",
  "short_name": "BookSummary",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#FFFAF0",
  "theme_color": "#C05621",
  "description": "Саммари нон-фикшн книг на русском языке",
  "orientation": "portrait-primary",
  "lang": "ru",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```
</action>
<acceptance_criteria>
- web/manifest.json contains `"name": "BookSummary — Саммари книг"`
- web/manifest.json contains `"background_color": "#FFFAF0"`
- web/manifest.json contains `"theme_color": "#C05621"`
- web/manifest.json contains `"display": "standalone"`
- web/manifest.json contains `"lang": "ru"`
- web/manifest.json contains `"purpose": "maskable"`
</acceptance_criteria>
</task>

<task id="4">
<title>Create project directory structure and core infrastructure files</title>
<read_first>
- /root/my-app/.planning/research/ARCHITECTURE.md (recommended project structure)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §5 (Hive init)
</read_first>
<action>
Create the following directory structure under lib/:

```
lib/
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   ├── utils/
│   └── router/
├── data/
│   ├── models/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── enums/
├── presentation/
│   ├── common/
│   ├── home/
│   │   ├── widgets/
│   │   └── providers/
│   ├── auth/
│   │   ├── widgets/
│   │   └── providers/
│   └── admin/
│       ├── widgets/
│       └── providers/
└── providers/
```

Create `lib/core/constants/app_constants.dart`:
```dart
abstract class AppConstants {
  static const String appName = 'BookSummary';
  static const Duration apiTimeout = Duration(seconds: 15);
  static const int maxSearchHistory = 10;
  static const int catalogPageSize = 20;
  static const int maxFreeSummaries = 5;
  static const double freePreviewPercent = 0.2;
  static const int maxFreeQuotes = 10;
  static const int defaultStorageLimitMb = 500;
}
```

Create `lib/core/constants/supabase_constants.dart`:
```dart
abstract class SupabaseConstants {
  static const String tableProfiles = 'profiles';
  static const String tableBooks = 'books';
  static const String tableCategories = 'categories';
  static const String tableBookCategories = 'book_categories';
  static const String tableSummaries = 'summaries';
  static const String tableKeyIdeas = 'key_ideas';
  static const String tableUserProgress = 'user_progress';
  static const String tableUserShelves = 'user_shelves';
  static const String tableUserHighlights = 'user_highlights';
  static const String tableUserDownloads = 'user_downloads';
  static const String tableUserRatings = 'user_ratings';
  static const String tableCollections = 'collections';
  static const String tableCollectionBooks = 'collection_books';
  static const String tableSubscriptions = 'subscriptions';
  static const String tablePayments = 'payments';
  static const String bucketCovers = 'covers';
  static const String bucketAudio = 'audio';
  static const String bucketSummaries = 'summaries';
}
```

Create `lib/core/constants/ui_constants.dart`:
```dart
abstract class UIConstants {
  static const double cardBorderRadius = 4.0;
  static const double buttonBorderRadius = 6.0;
  static const double chipBorderRadius = 4.0;
  static const double cardBorderWidth = 1.0;
  static const double bottomNavHeight = 64.0;
  static const double miniPlayerHeight = 64.0;
  static const double screenPadding = 16.0;
  static const double cardPadding = 8.0;
  static const double sectionSpacing = 24.0;
}
```

Create `lib/core/error/failures.dart`:
```dart
sealed class Failure {
  const Failure([this.message]);
  final String? message;

  const factory Failure.server([String? message]) = ServerFailure;
  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.offline([String? message]) = OfflineFailure;
  const factory Failure.auth([String? message]) = AuthFailure;
  const factory Failure.cache([String? message]) = CacheFailure;
  const factory Failure.unknown([String? message]) = UnknownFailure;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.message]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}
```

Create `lib/core/storage/hive_keys.dart`:
```dart
abstract class HiveKeys {
  static const String booksBox = 'books';
  static const String readingProgressBox = 'reading_progress';
  static const String highlightsBox = 'highlights';
  static const String userPrefsBox = 'user_prefs';
  static const String syncQueueBox = 'sync_queue';
}
```

Create `lib/core/storage/hive_init.dart`:
```dart
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'hive_keys.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  // Type adapters will be registered here as models are created
  // Open essential boxes
  await Future.wait([
    Hive.openBox<String>(HiveKeys.syncQueueBox),
    Hive.openBox(HiveKeys.userPrefsBox),
  ]);
}
```

Create `.env.example`:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Create `analysis_options.yaml` that includes very_good_analysis:
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    public_member_api_docs: false
```
</action>
<acceptance_criteria>
- lib/core/constants/app_constants.dart contains `class AppConstants`
- lib/core/constants/supabase_constants.dart contains `tableBooks = 'books'`
- lib/core/constants/ui_constants.dart contains `cardBorderRadius = 4.0`
- lib/core/error/failures.dart contains `sealed class Failure`
- lib/core/error/failures.dart contains `class ServerFailure extends Failure`
- lib/core/error/failures.dart contains `class OfflineFailure extends Failure`
- lib/core/storage/hive_keys.dart contains `booksBox = 'books'`
- lib/core/storage/hive_init.dart contains `Hive.initFlutter()`
- .env.example contains `SUPABASE_URL=`
- analysis_options.yaml contains `very_good_analysis`
- lib/domain/entities/ directory exists
- lib/data/models/ directory exists
- lib/presentation/common/ directory exists
- lib/providers/ directory exists
</acceptance_criteria>
</task>

<task id="5">
<title>Create main.dart and app.dart entry points</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §5 (main.dart init)
- /root/my-app/lib/core/storage/hive_init.dart (just created)
</read_first>
<action>
Create `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/storage/hive_init.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching — use bundled assets only
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Hive (IndexedDB on web)
  await initHive();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    const ProviderScope(
      child: BookSummaryApp(),
    ),
  );
}
```

Create `lib/app.dart` (placeholder — theme will be added in Plan 3):
```dart
import 'package:flutter/material.dart';

class BookSummaryApp extends StatelessWidget {
  const BookSummaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSummary',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('BookSummary'),
        ),
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- lib/main.dart contains `GoogleFonts.config.allowRuntimeFetching = false`
- lib/main.dart contains `Supabase.initialize(`
- lib/main.dart contains `ProviderScope(`
- lib/main.dart contains `await initHive()`
- lib/app.dart contains `class BookSummaryApp extends StatelessWidget`
</acceptance_criteria>
</task>

<task id="6">
<title>Subset fonts with pyftsubset and place in assets/fonts/</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §2 (Font Subsetting Strategy)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §8 (Font Subsetting Workflow)
</read_first>
<action>
Install fonttools and brotli if not present:
```bash
pip install fonttools brotli
```

Download the TTF source files for PlayfairDisplay (SemiBold, Bold) and SourceSans3 (Regular, SemiBold) from Google Fonts.

Create the `assets/fonts/` directory if it does not exist.

Run pyftsubset for each font file to produce Cyrillic + Latin subset .woff2 files:

```bash
pyftsubset PlayfairDisplay-SemiBold.ttf \
  --unicodes="U+0000-00FF,U+0100-024F,U+0400-04FF,U+0500-052F,U+2000-206F,U+2070-209F,U+20A0-20CF,U+2100-214F" \
  --layout-features='*' \
  --flavor=woff2 \
  --output-file=assets/fonts/PlayfairDisplay-SemiBold-subset.woff2

pyftsubset PlayfairDisplay-Bold.ttf \
  --unicodes="U+0000-00FF,U+0100-024F,U+0400-04FF,U+0500-052F,U+2000-206F,U+2070-209F,U+20A0-20CF,U+2100-214F" \
  --layout-features='*' \
  --flavor=woff2 \
  --output-file=assets/fonts/PlayfairDisplay-Bold-subset.woff2

pyftsubset SourceSans3-Regular.ttf \
  --unicodes="U+0000-00FF,U+0100-024F,U+0400-04FF,U+0500-052F,U+2000-206F,U+20A0-20CF" \
  --layout-features='*' \
  --flavor=woff2 \
  --output-file=assets/fonts/SourceSans3-Regular-subset.woff2

pyftsubset SourceSans3-SemiBold.ttf \
  --unicodes="U+0000-00FF,U+0100-024F,U+0400-04FF,U+0500-052F,U+2000-206F,U+20A0-20CF" \
  --layout-features='*' \
  --flavor=woff2 \
  --output-file=assets/fonts/SourceSans3-SemiBold-subset.woff2
```

Update the `flutter.fonts` section in pubspec.yaml to reference the subset .woff2 files:
```yaml
fonts:
  - family: PlayfairDisplay
    fonts:
      - asset: assets/fonts/PlayfairDisplay-SemiBold-subset.woff2
        weight: 600
      - asset: assets/fonts/PlayfairDisplay-Bold-subset.woff2
        weight: 700
  - family: SourceSans3
    fonts:
      - asset: assets/fonts/SourceSans3-Regular-subset.woff2
        weight: 400
      - asset: assets/fonts/SourceSans3-SemiBold-subset.woff2
        weight: 600
```
</action>
<acceptance_criteria>
- assets/fonts/PlayfairDisplay-SemiBold-subset.woff2 file exists
- assets/fonts/PlayfairDisplay-Bold-subset.woff2 file exists
- assets/fonts/SourceSans3-Regular-subset.woff2 file exists
- assets/fonts/SourceSans3-SemiBold-subset.woff2 file exists
- pubspec.yaml contains `PlayfairDisplay-SemiBold-subset.woff2`
- pubspec.yaml contains `PlayfairDisplay-Bold-subset.woff2`
- pubspec.yaml contains `SourceSans3-Regular-subset.woff2`
- pubspec.yaml contains `SourceSans3-SemiBold-subset.woff2`
</acceptance_criteria>
</task>

<task id="7">
<title>Create deferred font loading helper for reader fonts</title>
<read_first>
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §2 (Deferred Font Loading)
- /root/my-app/.planning/phases/01-foundation-design-system/01-CONTEXT.md (Font Loading Strategy)
</read_first>
<action>
Create `lib/core/theme/deferred_fonts.dart` with a `loadReaderFonts()` async function that loads Source Serif 4 and JetBrains Mono on demand using deferred import:

```dart
import 'package:google_fonts/google_fonts.dart' deferred as google_fonts_deferred;

/// Loads reader-specific fonts (Source Serif 4, JetBrains Mono) on demand.
/// Call this before navigating to the reader screen.
/// Playfair Display and Source Sans 3 are bundled as assets and always available.
Future<void> loadReaderFonts() async {
  await google_fonts_deferred.loadLibrary();
  // After loading, Source Serif 4 and JetBrains Mono are available
  // via google_fonts_deferred.GoogleFonts.sourceSerif4() etc.
}
```

This keeps the initial bundle small by deferring fonts only needed in the reader (Phase 4).
</action>
<acceptance_criteria>
- lib/core/theme/deferred_fonts.dart file exists
- File contains `loadReaderFonts()` function signature
- File contains `deferred as google_fonts_deferred`
- File contains `loadLibrary()`
</acceptance_criteria>
</task>

## Verification
1. `flutter pub get` completes without errors
2. `flutter analyze` runs (may show warnings but no errors from project code)
3. All directories under lib/ exist as specified
4. All core infrastructure files are present and contain expected classes

## Must-Haves
- Flutter Web project with CanvasKit renderer configured in web/index.html
- All Phase 1 dependencies installed and resolvable by `flutter pub get`
- PWA manifest.json with correct theme_color (#C05621), background_color (#FFFAF0), lang (ru), display (standalone)
- Hive CE initialized in main.dart before runApp
- Supabase initialized with environment variables (not hardcoded keys)
- Core directory structure matches ARCHITECTURE.md recommended layout
- analysis_options.yaml configured with very_good_analysis and generated file exclusions
