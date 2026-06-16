import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/dialogs/pernit_screen_detail_dialog.dart';
import '../../../screen_records/data/repos/screen_record_repository_dependencies.dart';
import '../../../screen_records/presentation/bloc/screen_records_cubit.dart';
import '../../../screen_records/presentation/widgets/screen_record_feature_section.dart';
import '../bloc/settings_record_cubits.dart';

class SettingsBasicsSection extends StatelessWidget {
  const SettingsBasicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScreenRecordFeatureSection(
      title: l10n.settingsBasicsSectionTitle,
      subtitle: l10n.settingsBasicsSectionSubtitle,
      screens: [
        PernitScreenDetailItem(
          icon: Icons.description_outlined,
          label: l10n.settingsSop,
          endpoint: '/v1/auth/erp/sops-lab/',
          records: const [
            PernitScreenRecord.api(
              title: 'SOP-LAB-001',
              fields: {
                'title': 'Moisture analysis',
                'document_number': 'SOP-LAB-001',
                'reference_method_name': 'Oven drying',
                'description': 'Standard lab moisture check',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.subject_outlined,
          label: l10n.settingsSopDetails,
          endpoint: '/v1/auth/erp/sop-details-lab/',
          records: const [
            PernitScreenRecord.api(
              title: 'Sample preparation',
              fields: {
                'sop': '1',
                'title': 'Sample preparation',
                'steps': 'Weigh sample, dry, cool, then re-weigh',
                'image': '',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.warehouse_outlined,
          label: l10n.settingsWarehouses,
          endpoint: '/v1/auth/erp/warehouses/',
          records: const [
            PernitScreenRecord.api(
              title: 'Main warehouse',
              fields: {'name': 'Main warehouse', 'location': 'Factory A'},
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.inventory_outlined,
          label: l10n.settingsProducts,
          endpoint: '/v1/auth/erp/products/',
          records: const [
            PernitScreenRecord.api(
              title: 'Starter Feed',
              fields: {
                'short_code': 'ST-FEED',
                'name': 'Starter Feed',
                'category': '1',
                'base_unit': '1',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.science_outlined,
          label: l10n.settingsRawMaterials,
          endpoint: '/v1/auth/erp/raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'Soybean Meal',
              fields: {
                'short_code': 'SBM',
                'name': 'Soybean Meal',
                'category_name': 'Protein',
                'base_unit_name': 'KG',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.category_outlined,
          label: l10n.settingsProductCategories,
          endpoint: '/v1/auth/erp/category-products/',
          records: const [
            PernitScreenRecord.api(
              title: 'Feed',
              fields: {
                'name': 'Feed',
                'description': 'Finished feed product category',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.category_outlined,
          label: l10n.settingsRawMaterialCategories,
          endpoint: '/v1/auth/erp/category-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'Protein',
              fields: {
                'name': 'Protein',
                'description': 'Protein source raw materials',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.functions_outlined,
          label: l10n.settingsFormulas,
          endpoint: '/v1/auth/erp/formulas/',
          records: const [
            PernitScreenRecord.api(
              title: 'F-STARTER',
              fields: {
                'short_code': 'F-STARTER',
                'name': 'Starter formula',
                'created_by': 'admin',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.list_alt_outlined,
          label: l10n.settingsFormulaDetails,
          endpoint: '/v1/auth/erp/formula-details/',
          records: const [
            PernitScreenRecord.api(
              title: 'SBM 18%',
              fields: {
                'formula': '1',
                'raw_material_name': 'Soybean Meal',
                'quantity': '4.500000',
                'percentage': '18.0000',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.rule_outlined,
          label: l10n.settingsProductionRules,
          endpoint: '/v1/auth/erp/production-rules/',
          records: const [
            PernitScreenRecord.api(
              title: 'Moisture guard',
              fields: {
                'name': 'Moisture guard',
                'expression': 'moisture <= 12',
                'priority': '1',
                'active': 'true',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.biotech_outlined,
          label: l10n.settingsLabParameters,
          endpoint: '/v1/auth/erp/parameter-labs/',
          records: const [
            PernitScreenRecord.api(
              title: 'Moisture',
              fields: {
                'name': 'Moisture',
                'unit': '1',
                'description': 'Moisture percentage',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.science_outlined,
          label: l10n.settingsPhysicalLabs,
          endpoint: '/v1/auth/erp/physical-labs/',
          records: const [
            PernitScreenRecord.api(
              title: 'Bulk density',
              fields: {
                'name': 'Bulk density',
                'description': 'Physical lab density parameter',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.tune_outlined,
          label: l10n.settingsAnalysisParameters,
          endpoint: '/v1/auth/erp/analysis-parameters-raw-materials/',
          records: const [
            PernitScreenRecord.api(
              title: 'Moisture range',
              fields: {
                'parameter_name': 'Moisture',
                'normal_min': '8.000000000',
                'normal_max': '12.000000000',
                'rejected_max': '15.000000000',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.fact_check_outlined,
          label: l10n.settingsReferenceMethods,
          endpoint: '/v1/auth/erp/reference-methods/',
          records: const [
            PernitScreenRecord.api(
              title: 'Oven drying',
              fields: {
                'name': 'Oven drying',
                'description': 'Moisture reference method',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.insights_outlined,
          label: l10n.settingsPredictiveResults,
          endpoint: '/v1/auth/erp/predictive-results/',
          records: const [
            PernitScreenRecord.api(
              title: 'Yield forecast',
              fields: {
                'target_type': 'production_order',
                'target_id': '1',
                'value': '23.40',
                'confidence': '0.91',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.local_shipping_outlined,
          label: l10n.settingsSuppliers,
          endpoint: '/v1/auth/erp/suppliers/',
          records: const [
            PernitScreenRecord.api(
              title: 'Delta Supply',
              fields: {
                'name': 'Delta Supply',
                'mail': 'supply@example.com',
                'phone': '+201000000000',
                'address': 'Cairo',
              },
            ),
          ],
        ),
        PernitScreenDetailItem(
          icon: Icons.groups_outlined,
          label: l10n.settingsCustomers,
          endpoint: '/v1/auth/erp/customers/',
          records: const [
            PernitScreenRecord.api(
              title: 'North Customer',
              fields: {
                'name': 'North Customer',
                'mail': 'customer@example.com',
                'phone': '+201111111111',
                'address': 'Alexandria',
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
    final dependencies = sl<ScreenRecordRepositoryDependencies>();

    return switch (item.endpoint) {
      '/v1/auth/erp/sops-lab/' => SopRecordsCubit(
        SopRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/sop-details-lab/' => SopDetailsRecordsCubit(
        SopDetailsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/warehouses/' => WarehousesRecordsCubit(
        WarehousesRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/products/' => ProductsRecordsCubit(
        ProductsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/raw-materials/' => RawMaterialsRecordsCubit(
        RawMaterialsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/category-products/' => ProductCategoriesRecordsCubit(
        ProductCategoriesRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/category-raw-materials/' =>
        RawMaterialCategoriesRecordsCubit(
          RawMaterialCategoriesRecordsRepository(records, dependencies),
        ),
      '/v1/auth/erp/formulas/' => FormulasRecordsCubit(
        FormulasRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/formula-details/' => FormulaDetailsRecordsCubit(
        FormulaDetailsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/production-rules/' => ProductionRulesRecordsCubit(
        ProductionRulesRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/parameter-labs/' => LabParametersRecordsCubit(
        LabParametersRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/physical-labs/' => PhysicalLabsRecordsCubit(
        PhysicalLabsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/analysis-parameters-raw-materials/' =>
        AnalysisParametersRecordsCubit(
          AnalysisParametersRecordsRepository(records, dependencies),
        ),
      '/v1/auth/erp/reference-methods/' => ReferenceMethodsRecordsCubit(
        ReferenceMethodsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/predictive-results/' => PredictiveResultsRecordsCubit(
        PredictiveResultsRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/suppliers/' => SuppliersRecordsCubit(
        SuppliersRecordsRepository(records, dependencies),
      ),
      '/v1/auth/erp/customers/' => CustomersRecordsCubit(
        CustomersRecordsRepository(records, dependencies),
      ),
      _ => throw UnsupportedError('Unsupported settings screen endpoint'),
    };
  }
}
