import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/export/inventory_pdf_exporter.dart';

void main() {
  group('InventoryPdfExporter', () {
    test('generateReport returns non-empty bytes with Arabic data', () async {
      final fontFile = File('assets/fonts/Cairo-Bold.ttf');
      ByteData? fontData;
      if (await fontFile.exists()) {
        final bytes = await fontFile.readAsBytes();
        fontData = ByteData.view(Uint8List.fromList(bytes).buffer);
      }

      final rows = [
        PdfInventoryRow(
          name: 'ذرة صفراء',
          warehouse: 'مخزن رئيسي',
          quantity: '100.000',
          available: '85.000',
          reserved: '15.000',
          unit: 'طن',
        ),
        PdfInventoryRow(
          name: 'Product XYZ',
          warehouse: 'Warehouse 2',
          quantity: '50.000',
          available: '50.000',
          reserved: '0.000',
          unit: 'kg',
        ),
      ];

      final bytes = await InventoryPdfExporter.generateReport(
        labels: PdfLabels(
          title: 'تقرير المخزون',
          item: 'الصنف',
          warehouse: 'المخزن',
          total: 'الإجمالي',
          available: 'المتاح',
          reserved: 'المحجوز',
          unit: 'الوحدة',
          lastLoaded: 'آخر تحميل',
          items: 'العناصر',
        ),
        lastLoadedAt: DateTime(2026, 7, 1, 14, 30),
        itemCount: rows.length,
        rows: rows,
        fontData: fontData,
        isRtl: true,
      );

      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.length, greaterThan(200));
    });

    test('Arabic PDF without fontData throws expected error', () async {
      final rows = [
        PdfInventoryRow(
          name: 'ذرة صفراء',
          warehouse: 'مخزن رئيسي',
          quantity: '100.000',
          available: '85.000',
          reserved: '15.000',
          unit: 'طن',
        ),
      ];

      expect(
        () async => InventoryPdfExporter.generateReport(
          labels: PdfLabels(
            title: 'تقرير المخزون',
            item: 'الصنف',
            warehouse: 'المخزن',
            total: 'الإجمالي',
            available: 'المتاح',
            reserved: 'المحجوز',
            unit: 'الوحدة',
            lastLoaded: 'آخر تحميل',
            items: 'العناصر',
          ),
          lastLoadedAt: DateTime(2026, 7, 1, 14, 30),
          itemCount: rows.length,
          rows: rows,
          fontData: null,
          isRtl: true,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Arabic PDF export requires a font'),
          ),
        ),
      );
    });

    test(
      'generateReport does not throw when fontData is null for English',
      () async {
        final rows = [
          PdfInventoryRow(
            name: 'Test',
            warehouse: 'WH',
            quantity: '1',
            available: '1',
            reserved: '0',
            unit: 'pc',
          ),
        ];

        final bytes = await InventoryPdfExporter.generateReport(
          labels: PdfLabels(
            title: 'Report',
            item: 'Item',
            warehouse: 'Warehouse',
            total: 'Total',
            available: 'Available',
            reserved: 'Reserved',
            unit: 'Unit',
            lastLoaded: 'Last loaded',
            items: 'Items',
          ),
          lastLoadedAt: null,
          itemCount: rows.length,
          rows: rows,
          fontData: null,
          isRtl: false,
        );

        expect(bytes.isNotEmpty, isTrue);
      },
    );

    test('generateReport handles empty row list without crash', () async {
      final bytes = await InventoryPdfExporter.generateReport(
        labels: PdfLabels(
          title: 'Empty Report',
          item: 'Item',
          warehouse: 'Warehouse',
          total: 'Total',
          available: 'Available',
          reserved: 'Reserved',
          unit: 'Unit',
          lastLoaded: 'Last loaded',
          items: 'Items',
        ),
        lastLoadedAt: null,
        itemCount: 0,
        rows: [],
        isRtl: false,
      );

      expect(bytes.isNotEmpty, isTrue);
    });

    test(
      'generateReport includes truncatedNote in PDF when provided',
      () async {
        final bytes = await InventoryPdfExporter.generateReport(
          labels: PdfLabels(
            title: 'Stock Report',
            item: 'Item',
            warehouse: 'Warehouse',
            total: 'Total',
            available: 'Available',
            reserved: 'Reserved',
            unit: 'Unit',
            lastLoaded: 'Last loaded',
            items: 'Items',
            truncatedNote:
                'Note: report may be incomplete (limited to 5000 items)',
          ),
          lastLoadedAt: DateTime(2026, 7, 1),
          itemCount: 5000,
          rows: List.generate(
            10,
            (i) => PdfInventoryRow(
              name: 'Item $i',
              warehouse: 'WH',
              quantity: '10',
              available: '10',
              reserved: '0',
              unit: 'kg',
            ),
          ),
          isRtl: false,
        );

        expect(bytes.isNotEmpty, isTrue);
        expect(bytes.length, greaterThan(200));
      },
    );
  });
}
