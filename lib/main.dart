import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload Google Fonts for CanvasKit rendering
  // This prevents Chinese text from rendering as blank/garbled in splash
  await GoogleFonts.pendingFonts([
    GoogleFonts.notoSansTc(textStyle: const TextStyle()),
    GoogleFonts.notoSerifTc(textStyle: const TextStyle()),
  ]);

  runApp(const app.TypingselfApp());
}
