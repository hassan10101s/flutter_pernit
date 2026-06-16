import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/dialogs/pernit_screen_detail_dialog.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';
import '../../../screen_records/presentation/widgets/screen_record_feature_section.dart';
import '../bloc/production_record_cubits.dart';

class ProductionScreensSection extends StatelessWidget {
  const ProductionScreensSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenRecordFeatureSection(
      title: l10n.menuProduction,
      subtitle: l10n.productionScreensSubtitle,
      screens: [
        PernitScreenDetailItem(
          icon: Icons.assignment_outlined,
          label: l10n.productionOrders,
          endpoint: '/v1/auth/erp/production-orders/',
          records: const [
            PernitScreenRecord.api(
              title: 'PO-001',
              fields: {
                'order_no': 'PO-001',
                'product_name': 'Starter Feed',
                'total_tons': '24.00',
                'status': 'pending',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.list_alt_outlined,
          label: l10n.productionOrderDetails,
          endpoint: '/v1/auth/erp/production-order-details/',
          records: const [
            PernitScreenRecord.api(
              title: 'Soybean meal line',
              fields: {
                'production_order': '1',
                'raw_material_name': 'Soybean Meal',
                'quantity_tons': '4.50',
                'raw_material_received': '17',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.science_outlined,
          label: l10n.productionLabSamples,
          endpoint: '/v1/auth/erp/lab-samples-of-production/',
          records: const [
            PernitScreenRecord.api(
              title: 'PROD-SAMPLE-001',
              fields: {
                'production_order_code': 'PO-001',
                'quantity_taken': '1.00',
                'status': 'pending',
                'taken_by': 'quality_user',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.biotech_outlined,
          label: l10n.productionLabResults,
          endpoint: '/v1/auth/erp/lab-results-production/',
          records: const [
            PernitScreenRecord.api(
              title: 'Protein result',
              fields: {
                'sample_no': 'PROD-SAMPLE-001',
                'parameter_name': 'Protein',
                'value': '21.4',
                'is_within_range': 'true',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.lock_clock_outlined,
          label: l10n.productionReserveMaterials,
          endpoint: '/v1/auth/erp/production-orders/{id}/reserve_materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'PO-001 reserve action',
              fields: {
                'method': 'POST',
                'resource': 'ProductionOrder',
                'requires': 'production order id',
                'result': 'reserved materials',
              },
            ),
          ],
        ),
      ],
      createCubit: _createCubit,
    );
  }

  ScreenRecordsCubit _createCubit(
    PernitScreenDetailItem item,
    List<PernitScreenRecord> records,
  ) {
    return switch (item.endpoint) {
      '/v1/auth/erp/production-orders/' => ProductionOrdersRecordsCubit(
        ProductionOrdersRecordsRepository(records),
      ),
      '/v1/auth/erp/production-order-details/' =>
        ProductionOrderDetailsRecordsCubit(
          ProductionOrderDetailsRecordsRepository(records),
        ),
      '/v1/auth/erp/lab-samples-of-production/' =>
        ProductionLabSamplesRecordsCubit(
          ProductionLabSamplesRecordsRepository(records),
        ),
      '/v1/auth/erp/lab-results-production/' =>
        ProductionLabResultsRecordsCubit(
          ProductionLabResultsRecordsRepository(records),
        ),
      '/v1/auth/erp/production-orders/{id}/reserve_materials/' =>
        ProductionReserveMaterialsRecordsCubit(
          ProductionReserveMaterialsRecordsRepository(records),
        ),
      _ => throw UnsupportedError('Unsupported production screen endpoint'),
    };
  }
}
