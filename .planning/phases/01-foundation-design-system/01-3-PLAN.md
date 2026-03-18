---
phase: 1
plan: 3
name: design-system-theme-and-components
wave: 2
depends_on: [1]
requirements: [DSGN-01, DSGN-02, DSGN-04, DSGN-06]
files_modified:
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_typography.dart
  - lib/core/theme/app_theme.dart
  - lib/presentation/common/shimmer_loader.dart
  - lib/presentation/common/book_card.dart
  - lib/presentation/common/book_card_skeleton.dart
  - lib/presentation/common/section_header.dart
  - lib/presentation/common/app_chip.dart
autonomous: true
---

# Plan 01-3: Design System — Theme and Components

## Objective
Implement the full "Warm Brutalism" design system with light and dark ThemeData, color palette, typography (Playfair Display headings, Source Sans 3 body), and core reusable widgets (ShimmerLoader, BookCard, BookCardSkeleton, SectionHeader, AppChip) with WCAG AA compliance and semantic labels.

## Tasks

<task id="1">
<title>Create AppColors with light and dark palettes</title>
<read_first>
- /root/my-app/.planning/PROJECT.md §Дизайн-концепция (exact hex codes for both themes)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §2 (AppColors implementation)
</read_first>
<action>
Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Light theme
  static const Color primaryLight = Color(0xFFC05621);       // Terracotta
  static const Color primaryVariantLight = Color(0xFF9C4221); // Dark clay
  static const Color secondaryLight = Color(0xFFD69E2E);      // Warm yellow
  static const Color backgroundLight = Color(0xFFFFFAF0);     // Cream
  static const Color surfaceLight = Color(0xFFFEFCF3);        // Sandy
  static const Color onBackgroundLight = Color(0xFF1A202C);    // Near black
  static const Color onSurfaceLight = Color(0xFF718096);       // Warm gray
  static const Color cardBorderLight = Color(0xFFE2D8C3);      // Sand border

  // Dark theme
  static const Color backgroundDark = Color(0xFF1A1A2E);      // Dark graphite
  static const Color surfaceDark = Color(0xFF232340);
  static const Color primaryDark = Color(0xFFED8936);          // Light terracotta
  static const Color onBackgroundDark = Color(0xFFFEFCF3);     // Cream
  static const Color onSurfaceDark = Color(0xFFA0AEC0);        // Muted gray
  static const Color cardBorderDark = Color(0xFF3D3D5C);       // Dark border

  // Shared
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);

  // Shimmer colors
  static const Color shimmerBaseLight = Color(0xFFF5EFE0);     // Warm sandy base
  static const Color shimmerHighlightLight = Color(0xFFFEFCF3); // Sandy highlight
  static const Color shimmerBaseDark = Color(0xFF2D2D45);       // Dark shimmer base
  static const Color shimmerHighlightDark = Color(0xFF3D3D5C);  // Dark shimmer highlight
}
```

Every color must be a `const Color` with the exact hex value from the design spec.
</action>
<acceptance_criteria>
- lib/core/theme/app_colors.dart contains `abstract class AppColors`
- File contains `primaryLight = Color(0xFFC05621)`
- File contains `backgroundLight = Color(0xFFFFFAF0)`
- File contains `backgroundDark = Color(0xFF1A1A2E)`
- File contains `primaryDark = Color(0xFFED8936)`
- File contains `surfaceDark = Color(0xFF232340)`
- File contains `onBackgroundDark = Color(0xFFFEFCF3)`
- File contains `cardBorderLight = Color(0xFFE2D8C3)`
- File contains `shimmerBaseLight = Color(0xFFF5EFE0)`
- File contains `error = Color(0xFFE53E3E)`
</acceptance_criteria>
</task>

<task id="2">
<title>Create AppTypography with Playfair Display and Source Sans 3</title>
<read_first>
- /root/my-app/lib/core/theme/app_colors.dart (colors for text)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §2 (AppTypography)
- /root/my-app/.planning/PROJECT.md §Типографика (font families and roles)
</read_first>
<action>
Create `lib/core/theme/app_typography.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final Color onBg = brightness == Brightness.light
        ? AppColors.onBackgroundLight
        : AppColors.onBackgroundDark;

    final Color onSurface = brightness == Brightness.light
        ? AppColors.onSurfaceLight
        : AppColors.onSurfaceDark;

    return TextTheme(
      // Playfair Display for headings
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onBg,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      // Source Sans 3 for body text
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onBg,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onBg,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onBg,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );
  }
}
```

Headings (display*, headline*) use `GoogleFonts.playfairDisplay()`.
Body/labels (title*, body*, label*) use `GoogleFonts.sourceSans3()`.
</action>
<acceptance_criteria>
- lib/core/theme/app_typography.dart contains `abstract class AppTypography`
- File contains `GoogleFonts.playfairDisplay(` (at least 5 occurrences for heading styles)
- File contains `GoogleFonts.sourceSans3(` (at least 7 occurrences for body/label styles)
- File contains `fontSize: 32` (displayLarge)
- File contains `fontSize: 14` (bodyMedium)
- File contains `Brightness brightness` parameter in textTheme method
- File contains `import 'app_colors.dart'`
</acceptance_criteria>
</task>

<task id="3">
<title>Create AppTheme with full light and dark ThemeData</title>
<read_first>
- /root/my-app/lib/core/theme/app_colors.dart (color palette)
- /root/my-app/lib/core/theme/app_typography.dart (text theme)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §2 (AppTheme)
- /root/my-app/.planning/PROJECT.md §Компоненты (card 4px radius, button 6px radius, no shadows)
</read_first>
<action>
Create `lib/core/theme/app_theme.dart` with both `light()` and `dark()` static methods returning fully configured ThemeData:

Light theme must include:
- `useMaterial3: true`
- `brightness: Brightness.light`
- ColorScheme with primary `#C05621`, primaryContainer `#9C4221`, secondary `#D69E2E`, surface `#FEFCF3`
- `scaffoldBackgroundColor: AppColors.backgroundLight` (#FFFAF0)
- textTheme from AppTypography.textTheme(Brightness.light)
- CardTheme: elevation 0, borderRadius 4px, side BorderSide(color: #E2D8C3, width: 1)
- ChipThemeData: backgroundColor surfaceLight, selectedColor primaryLight, borderRadius 4px, side BorderSide(#E2D8C3)
- ElevatedButtonTheme: backgroundColor primaryLight, foregroundColor white, elevation 0, borderRadius 6px, padding (24h, 14v)
- OutlinedButtonTheme: foregroundColor primaryLight, elevation 0, borderRadius 6px, side primaryLight
- TextButtonTheme: foregroundColor primaryLight
- DividerTheme: color cardBorderLight, thickness 1
- AppBarTheme: backgroundColor backgroundLight, elevation 0, scrolledUnderElevation 0, no shadow
- BottomNavigationBarTheme: elevation 0, backgroundColor backgroundLight

Dark theme must include:
- `brightness: Brightness.dark`
- ColorScheme with primary `#ED8936`, surface `#232340`, onPrimary `#1A1A2E`, onSurface `#FEFCF3`
- `scaffoldBackgroundColor: AppColors.backgroundDark` (#1A1A2E)
- textTheme from AppTypography.textTheme(Brightness.dark)
- CardTheme: elevation 0, borderRadius 4px, side BorderSide(color: cardBorderDark, width: 1)
- All button/chip/appbar themes mirrored with dark colors
- scrolledUnderElevation: 0 on AppBarTheme

Both themes: NO elevation/shadow on any component. Warm Brutalism = borders and translate, never box-shadow.
</action>
<acceptance_criteria>
- lib/core/theme/app_theme.dart contains `abstract class AppTheme`
- File contains `static ThemeData light()`
- File contains `static ThemeData dark()`
- File contains `useMaterial3: true` (at least 2 occurrences)
- File contains `elevation: 0` (at least 4 occurrences across card, button, appbar)
- File contains `BorderRadius.circular(4)` (card and chip border radius)
- File contains `BorderRadius.circular(6)` (button border radius)
- File contains `scrolledUnderElevation: 0`
- File contains `AppColors.backgroundLight` (scaffoldBackgroundColor for light)
- File contains `AppColors.backgroundDark` (scaffoldBackgroundColor for dark)
- File contains `AppTypography.textTheme(Brightness.light)`
- File contains `AppTypography.textTheme(Brightness.dark)`
- File contains `BottomNavigationBarThemeData(` or `bottomNavigationBarTheme:`
</acceptance_criteria>
</task>

<task id="4">
<title>Update app.dart to use theme system with light/dark support</title>
<read_first>
- /root/my-app/lib/app.dart (current placeholder)
- /root/my-app/lib/core/theme/app_theme.dart (just created)
</read_first>
<action>
Update `lib/app.dart` to use the theme system. The app should support light and dark themes via ThemeMode:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

class BookSummaryApp extends ConsumerWidget {
  const BookSummaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BookSummary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('BookSummary'),
        ),
      ),
    );
  }
}
```

Change from `StatelessWidget` to `ConsumerWidget` so Riverpod can later control theme mode.
</action>
<acceptance_criteria>
- lib/app.dart contains `ConsumerWidget`
- lib/app.dart contains `AppTheme.light()`
- lib/app.dart contains `AppTheme.dark()`
- lib/app.dart contains `ThemeMode.system`
- lib/app.dart contains `import 'core/theme/app_theme.dart'`
</acceptance_criteria>
</task>

<task id="5">
<title>Create ShimmerLoader widget with warm sandy colors</title>
<read_first>
- /root/my-app/lib/core/theme/app_colors.dart (shimmer colors)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §3 (ShimmerLoader)
</read_first>
<action>
Create `lib/presentation/common/shimmer_loader.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Loading content',
      child: Shimmer.fromColors(
        baseColor: isDark
            ? AppColors.shimmerBaseDark
            : AppColors.shimmerBaseLight,
        highlightColor: isDark
            ? AppColors.shimmerHighlightDark
            : AppColors.shimmerHighlightLight,
        child: child,
      ),
    );
  }
}
```

Must use warm sandy colors `#F5EFE0` base / `#FEFCF3` highlight for light theme.
Must use `#2D2D45` base / `#3D3D5C` highlight for dark theme.
Must include `Semantics` widget with label for accessibility (DSGN-06).
</action>
<acceptance_criteria>
- lib/presentation/common/shimmer_loader.dart contains `class ShimmerLoader extends StatelessWidget`
- File contains `Shimmer.fromColors(`
- File contains `AppColors.shimmerBaseLight`
- File contains `AppColors.shimmerBaseDark`
- File contains `AppColors.shimmerHighlightLight`
- File contains `AppColors.shimmerHighlightDark`
- File contains `Semantics(`
</acceptance_criteria>
</task>

<task id="6">
<title>Create BookCard widget with Warm Brutalism styling</title>
<read_first>
- /root/my-app/lib/core/theme/app_colors.dart (colors)
- /root/my-app/lib/core/constants/ui_constants.dart (border radius values)
- /root/my-app/.planning/phases/01-foundation-design-system/01-RESEARCH.md §3 (BookCard widget)
- /root/my-app/.planning/PROJECT.md §Компоненты (card specs: 4px radius, 1px border, translate on press)
</read_first>
<action>
Create `lib/presentation/common/book_card.dart`:

A card widget that displays a book cover, title, author, and read time. Specs:
- `BoxDecoration` with `borderRadius: BorderRadius.circular(4)` and `Border.all(color: theme card border, width: 1)`
- Zero elevation (no BoxShadow)
- Translate down 2px on press (using AnimatedContainer or GestureDetector + Transform.translate)
- Cover image aspect ratio 2:3
- Title: `textTheme.titleMedium`, maxLines 2, overflow ellipsis
- Author: `textTheme.bodySmall`, maxLines 1
- Read time: `textTheme.bodySmall` with onSurface color, format "${minutes} мин"
- Include `Semantics` widget wrapping the card with `label: '$title by $author, $readTimeMinutes minute read'`
- Accept parameters: `String title`, `String author`, `String? coverUrl`, `int readTimeMinutes`, `VoidCallback? onTap`
- Use `Theme.of(context)` for all colors (theme-aware, works in both light and dark)
</action>
<acceptance_criteria>
- lib/presentation/common/book_card.dart contains `class BookCard extends StatelessWidget` or `StatefulWidget`
- File contains `BorderRadius.circular(4)`
- File contains `Border.all(`
- File contains `AspectRatio(`
- File contains `мин`  (Russian "minutes" abbreviation in read time display)
- File contains `Semantics(`
- File contains `maxLines: 2` (title)
- File contains `TextOverflow.ellipsis`
- File does NOT contain `elevation` or `BoxShadow`
- File contains `Transform.translate(` OR `transform: Matrix4`
</acceptance_criteria>
</task>

<task id="7">
<title>Create BookCardSkeleton widget</title>
<read_first>
- /root/my-app/lib/presentation/common/shimmer_loader.dart (shimmer wrapper)
- /root/my-app/lib/presentation/common/book_card.dart (card layout to match)
- /root/my-app/lib/core/constants/ui_constants.dart (dimensions)
</read_first>
<action>
Create `lib/presentation/common/book_card_skeleton.dart`:

A skeleton placeholder that matches the BookCard layout, wrapped in ShimmerLoader:
- Same outer dimensions and border radius as BookCard (4px)
- Cover area: Container with shimmer color filling 2:3 aspect ratio
- Title area: two shimmer rectangles (80% and 60% width, 14px height each)
- Author area: one shimmer rectangle (50% width, 12px height)
- Read time area: one shimmer rectangle (30% width, 12px height)
- All shimmer rectangles use `Container` with `decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))`
- Wrapped in `ShimmerLoader` widget

```dart
import 'package:flutter/material.dart';
import 'shimmer_loader.dart';

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
</action>
<acceptance_criteria>
- lib/presentation/common/book_card_skeleton.dart contains `class BookCardSkeleton extends StatelessWidget`
- File contains `ShimmerLoader(`
- File contains `AspectRatio(`
- File contains `BorderRadius.circular(4)`
- File contains `FractionallySizedBox(`
</acceptance_criteria>
</task>

<task id="8">
<title>Create SectionHeader and AppChip widgets</title>
<read_first>
- /root/my-app/lib/core/theme/app_colors.dart (colors)
- /root/my-app/.planning/PROJECT.md §Компоненты (chip specs: 4px radius, active filled terracotta)
</read_first>
<action>
Create `lib/presentation/common/section_header.dart`:

```dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllTap,
    this.seeAllLabel = 'Все',
  });

  final String title;
  final VoidCallback? onSeeAllTap;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (onSeeAllTap != null)
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                seeAllLabel,
                semanticsLabel: 'See all $title',
              ),
            ),
        ],
      ),
    );
  }
}
```

Create `lib/presentation/common/app_chip.dart`:

```dart
import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label${isSelected ? ', selected' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
```

Chip specs: 4px border radius, active state filled with primary color (terracotta), inactive has border only.
</action>
<acceptance_criteria>
- lib/presentation/common/section_header.dart contains `class SectionHeader extends StatelessWidget`
- lib/presentation/common/section_header.dart contains `headlineMedium`
- lib/presentation/common/section_header.dart contains `'Все'` (default "See all" label in Russian)
- lib/presentation/common/app_chip.dart contains `class AppChip extends StatelessWidget`
- lib/presentation/common/app_chip.dart contains `BorderRadius.circular(4)`
- lib/presentation/common/app_chip.dart contains `theme.colorScheme.primary`
- lib/presentation/common/app_chip.dart contains `Semantics(`
</acceptance_criteria>
</task>

## Verification
1. `flutter analyze` passes without errors on theme and widget files
2. AppTheme.light() and AppTheme.dark() both return valid ThemeData
3. All color hex values match the design spec exactly
4. All widgets include Semantics for accessibility (DSGN-06)
5. No `elevation`, `BoxShadow`, or `shadow` in any widget (Warm Brutalism requirement)

## Must-Haves
- Light theme with primary #C05621, background #FFFAF0, surface #FEFCF3, card border #E2D8C3
- Dark theme with primary #ED8936, background #1A1A2E, surface #232340
- Playfair Display for all heading text styles (display*, headline*)
- Source Sans 3 for all body/label text styles (title*, body*, label*)
- ShimmerLoader with warm sandy colors (not gray) — base #F5EFE0, highlight #FEFCF3 for light
- All card and chip components use 4px border radius, buttons use 6px
- Zero elevation/shadow on cards, buttons, chips, and app bar
- Semantics labels on all interactive/content widgets (WCAG AA)
