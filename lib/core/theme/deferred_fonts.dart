// ignore_for_file: unused_import
import 'package:google_fonts/google_fonts.dart' deferred as google_fonts_deferred;

/// Loads reader-specific fonts (Source Serif 4, JetBrains Mono)
/// on demand. Call this before navigating to the reader screen.
/// Playfair Display and Source Sans 3 are bundled as assets
/// and always available.
Future<void> loadReaderFonts() async {
  await google_fonts_deferred.loadLibrary();
}
