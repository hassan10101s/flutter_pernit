import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/dialogs/pernit_screen_detail_dialog.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';
import '../../../screen_records/presentation/widgets/screen_record_feature_section.dart';
import '../bloc/quality_record_cubits.dart';

class QualityScreensSection extends StatelessWidget {
  const QualityScreensSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenRecordFeatureSection(
      title: l10n.menuQuality,
      subtitle: l10n.qualityScreensSubtitle,
      screens: [
        PernitScreenDetailItem(
          icon: Icons.science_outlined,
          label: l10n.qualityLabSamplesRawMaterials,
          endpoint: '/v1/auth/erp/lab-samples-of-received-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'RM-SAMPLE-001',
              fields: {
                'sample_no': 'RM-SAMPLE-001',
                'status': 'pending',
                'received_raw_material_name': 'Corn Gluten',
                'taken_by': 'quality_user',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.biotech_outlined,
          label: l10n.qualityLabResultsRawMaterials,
          endpoint: '/v1/auth/erp/lab-results-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'Moisture result',
              fields: {
                'sample_no': 'RM-SAMPLE-001',
                'parameter_name': 'Moisture',
                'value': '11.8',
                'is_within_range': 'true',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.speed_outlined,
          label: l10n.qualityPhysicalLabResultsRawMaterials,
          endpoint: '/v1/auth/erp/physical-lab-results-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'Bulk density',
              fields: {
                'sample_no': 'RM-SAMPLE-001',
                'physical_parameter': 'Bulk density',
                'value': '0.62',
                'reference_name': 'Density reference',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.fact_check_outlined,
          label: l10n.qualityChecksRawMaterials,
          endpoint: '/v1/auth/erp/quality-checks-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'QC-RM-001',
              fields: {
                'received_raw_material': '1',
                'status': 'accepted',
                'comments': 'Within accepted limits',
                'metadata': '{}',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.verified_outlined,
          label: l10n.qualityChecksProduction,
          endpoint: '/v1/auth/erp/quality-checks-production/',
          records: const [
            PernitScreenRecord.api(
              title: 'QC-PROD-001',
              fields: {
                'production_order_code': 'PO-001',
                'status': 'release',
                'comments': 'Ready for stock',
                'received_product': '1',
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
      '/v1/auth/erp/lab-samples-of-received-raw-materials/' =>
        RawMaterialLabSamplesRecordsCubit(
          RawMaterialLabSamplesRecordsRepository(records),
        ),
      '/v1/auth/erp/lab-results-raw-materials/' =>
        RawMaterialLabResultsRecordsCubit(
          RawMaterialLabResultsRecordsRepository(records),
        ),
      '/v1/auth/erp/physical-lab-results-raw-materials/' =>
        RawMaterialPhysicalLabResultsRecordsCubit(
          RawMaterialPhysicalLabResultsRecordsRepository(records),
        ),
      '/v1/auth/erp/quality-checks-raw-materials/' =>
        RawMaterialQualityChecksRecordsCubit(
          RawMaterialQualityChecksRecordsRepository(records),
        ),
      '/v1/auth/erp/quality-checks-production/' =>
        ProductionQualityChecksRecordsCubit(
          ProductionQualityChecksRecordsRepository(records),
        ),
      _ => throw UnsupportedError('Unsupported quality screen endpoint'),
    };
  }
}
