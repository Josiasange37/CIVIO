import 'package:flutter/services.dart';

// TODO: Re-enable pdf/printing imports when building for Android
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generateOfficialDocument({
    required String title,
    required String name,
    required String university,
    required String level,
    required String major,
    required String content,
  }) async {
    // Stub: PDF generation disabled for Linux desktop testing
    throw UnsupportedError('PDF generation is not available on Linux desktop. Re-enable pdf/printing in pubspec.yaml for Android builds.');
  }

  static Future<void> saveAndShare(Uint8List bytes, String filename) async {
    // Stub: PDF sharing disabled for Linux desktop testing
    throw UnsupportedError('PDF sharing is not available on Linux desktop.');
  }
}
