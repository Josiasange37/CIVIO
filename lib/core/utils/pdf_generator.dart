import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generateOfficialDocument({
    required String title,
    required String name,
    required String university,
    required String level,
    required String major,
    required String content,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      pw.Text(university, style: pw.TextStyle(font: font, fontSize: 8)),
                      pw.Text('$level — $major', style: pw.TextStyle(font: font, fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RÉPUBLIQUE DU CAMEROUN', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                      pw.Text('Paix — Travail — Patrie', style: pw.TextStyle(font: font, fontSize: 7, fontStyle: pw.FontStyle.italic)),
                      pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
                      pw.Text('Yaoundé, le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              
              // Recipient
              pw.Text('À l\'attention de M. le Ministre', style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.Text('MINESUP — Yaoundé', style: pw.TextStyle(font: fontBold, fontSize: 11)),
              pw.SizedBox(height: 30),

              // Subject
              pw.Center(
                child: pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(font: fontBold, fontSize: 14, decoration: pw.TextDecoration.underline),
                ),
              ),
              pw.SizedBox(height: 30),

              // Body
              pw.Text(content, style: pw.TextStyle(font: font, fontSize: 12, height: 1.5)),
              
              pw.SizedBox(height: 40),
              
              // Footer / Signature
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('L\'intéressé(e)', style: pw.TextStyle(font: font, fontSize: 10, decoration: pw.TextDecoration.underline)),
                    pw.SizedBox(height: 30),
                    pw.Text(name, style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> saveAndShare(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
