import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfLabels {
  final String item;
  final String warehouse;
  final String total;
  final String available;
  final String reserved;
  final String unit;
  final String lastLoaded;
  final String items;
  final String title;
  final String? truncatedNote;

  const PdfLabels({
    required this.item,
    required this.warehouse,
    required this.total,
    required this.available,
    required this.reserved,
    required this.unit,
    required this.lastLoaded,
    required this.items,
    required this.title,
    this.truncatedNote,
  });
}

class PdfInventoryRow {
  final String name;
  final String warehouse;
  final String quantity;
  final String available;
  final String reserved;
  final String unit;

  const PdfInventoryRow({
    required this.name,
    required this.warehouse,
    required this.quantity,
    required this.available,
    required this.reserved,
    required this.unit,
  });
}

bool _containsArabic(String text) {
  return text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
}

bool _contentRequiresArabicFont({
  required PdfLabels labels,
  required List<PdfInventoryRow> rows,
}) {
  if (_containsArabic(labels.title) ||
      _containsArabic(labels.item) ||
      _containsArabic(labels.warehouse)) {
    return true;
  }
  for (final row in rows) {
    if (_containsArabic(row.name) || _containsArabic(row.warehouse)) {
      return true;
    }
  }
  return false;
}

abstract class InventoryPdfExporter {
  static Future<Uint8List> generateReport({
    required PdfLabels labels,
    required DateTime? lastLoadedAt,
    required int itemCount,
    required List<PdfInventoryRow> rows,
    ByteData? fontData,
    bool isRtl = false,
  }) async {
    if (_contentRequiresArabicFont(labels: labels, rows: rows) &&
        fontData == null) {
      throw Exception(
        'Arabic PDF export requires a font. Load Cairo-Bold.ttf and pass as fontData.',
      );
    }

    final pdf = pw.Document();
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm');
    final loadedStr = lastLoadedAt != null
        ? timeFormat.format(lastLoadedAt)
        : '-';

    pw.Font? font;
    try {
      font = fontData != null ? pw.Font.ttf(fontData) : null;
    } catch (_) {
      font = null;
    }

    final headerStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      font: font,
    );
    final cellStyle = pw.TextStyle(fontSize: 9, font: font);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Directionality(
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Header(
              level: 0,
              child: pw.Text(
                labels.title,
                style: pw.TextStyle(fontSize: 18, font: font),
              ),
            ),
          ),
          pw.Directionality(
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Paragraph(
              text:
                  '${labels.lastLoaded}: $loadedStr  |  ${labels.items}: $itemCount',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                font: font,
              ),
            ),
          ),
          if (labels.truncatedNote != null)
            pw.Directionality(
              textDirection: isRtl
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              child: pw.Paragraph(
                text: labels.truncatedNote!,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.orange700,
                  font: font,
                ),
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Directionality(
            textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.TableHelper.fromTextArray(
              headerStyle: headerStyle,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
              ),
              cellStyle: cellStyle,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerLeft,
              },
              headers: [
                labels.item,
                labels.warehouse,
                labels.total,
                labels.available,
                labels.reserved,
                labels.unit,
              ],
              data: [
                for (final row in rows)
                  [
                    pw.Directionality(
                      textDirection: isRtl
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(row.name, style: cellStyle),
                    ),
                    pw.Directionality(
                      textDirection: isRtl
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(row.warehouse, style: cellStyle),
                    ),
                    pw.Directionality(
                      textDirection: pw.TextDirection.ltr,
                      child: pw.Text(row.quantity, style: cellStyle),
                    ),
                    pw.Directionality(
                      textDirection: pw.TextDirection.ltr,
                      child: pw.Text(row.available, style: cellStyle),
                    ),
                    pw.Directionality(
                      textDirection: pw.TextDirection.ltr,
                      child: pw.Text(row.reserved, style: cellStyle),
                    ),
                    pw.Directionality(
                      textDirection: pw.TextDirection.ltr,
                      child: pw.Text(row.unit, style: cellStyle),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> sharePdf(
    Uint8List bytes, {
    required String filename,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
