import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/dialogs/pernit_screen_detail_dialog.dart';
import '../../../screen_records/data/repos/screen_record_repository_dependencies.dart';
import '../../../screen_records/presentation/widgets/screen_record_feature_section.dart';
import '../bloc/settings_record_cubits.dart';

class SettingsUnitsSection extends StatelessWidget {
  const SettingsUnitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dependencies = sl<ScreenRecordRepositoryDependencies>();

    return ScreenRecordFeatureSection(
      title: l10n.settingsUnitsSectionTitle,
      subtitle: l10n.settingsUnitsSectionSubtitle,
      screens: [
        PernitScreenDetailItem(
          icon: Icons.straighten_outlined,
          label: l10n.settingsUnits,
          endpoint: '/v1/auth/erp/units/',
          records: const [
            PernitScreenRecord.api(
              title: 'KG',
              fields: {
                'short_code': 'KG',
                'name': 'Kilogram',
                'to_base_factor': '1.000000000',
              },
            ),
            PernitScreenRecord.api(
              title: 'TON',
              fields: {
                'short_code': 'TON',
                'name': 'Metric ton',
                'to_base_factor': '1000.000000000',
              },
            ),
          ],
        ),
      ],
      createCubit: (_, records) =>
          UnitsRecordsCubit(UnitsRecordsRepository(records, dependencies)),
    );
  }
}
