import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/raw_material_workflow.dart';

class RawMaterialAnalysisSheet extends StatefulWidget {
  final RawMaterialAnalysisWorkspace workspace;
  final bool isWorking;
  final Future<bool> Function(RawMaterialAnalysisSubmission submission) onSave;

  const RawMaterialAnalysisSheet({
    super.key,
    required this.workspace,
    required this.isWorking,
    required this.onSave,
  });

  @override
  State<RawMaterialAnalysisSheet> createState() =>
      _RawMaterialAnalysisSheetState();
}

class _RawMaterialAnalysisSheetState extends State<RawMaterialAnalysisSheet> {
  final _chemicalControllers = <int, TextEditingController>{};
  final _physicalControllers = <int, TextEditingController>{};
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _syncWorkspace();
  }

  @override
  void didUpdateWidget(covariant RawMaterialAnalysisSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace.sample.id != widget.workspace.sample.id) {
      _disposeControllers();
      _syncWorkspace();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _syncWorkspace() {
    for (final parameter in widget.workspace.chemicalParameters) {
      _chemicalControllers[parameter.id] = TextEditingController(
        text: parameter.value?.toString() ?? '',
      );
    }
    for (final parameter in widget.workspace.physicalParameters) {
      _physicalControllers[parameter.id] = TextEditingController(
        text: parameter.value ?? '',
      );
    }
  }

  void _disposeControllers() {
    for (final controller in _chemicalControllers.values) {
      controller.dispose();
    }
    for (final controller in _physicalControllers.values) {
      controller.dispose();
    }
    _chemicalControllers.clear();
    _physicalControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workspace = widget.workspace;
    final sampleNumber =
        workspace.sample.sampleNumber ??
            l10n.entryIdPrefix(workspace.sample.id.toString());

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.94,
          ),
          child: Column(
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                decoration: BoxDecoration(
                  color: PernitColors.border,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.rawAnalysisTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: PernitFontWeights.bold,
                                      ),
                                ),
                                Text(
                                  '${workspace.rawMaterialName}${l10n.separatorDot}'
                                  '${l10n.rawAnalysisSampleNumber(sampleNumber)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: PernitColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: widget.isWorking
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      _AnalysisSummary(workspace: workspace),
                      if (workspace.chemicalParameters.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        _SectionTitle(
                          icon: Icons.biotech_outlined,
                          title: l10n.rawAnalysisChemical,
                        ),
                        SizedBox(height: 5.h),
                        for (final parameter
                            in workspace.chemicalParameters) ...[
                          _ChemicalParameterField(
                            parameter: parameter,
                            controller: _chemicalControllers[parameter.id]!,
                            enabled: !widget.isWorking,
                          ),
                          SizedBox(height: 6.h),
                        ],
                      ],
                      if (workspace.physicalParameters.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _SectionTitle(
                          icon: Icons.straighten_outlined,
                          title: l10n.rawAnalysisPhysical,
                        ),
                        SizedBox(height: 5.h),
                        for (final parameter
                            in workspace.physicalParameters) ...[
                          _PhysicalParameterField(
                            parameter: parameter,
                            controller: _physicalControllers[parameter.id]!,
                            enabled: !widget.isWorking,
                          ),
                          SizedBox(height: 6.h),
                        ],
                      ],
                      if (_validationMessage != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _validationMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: PernitColors.danger),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      PernitButton(
                        label: l10n.rawAnalysisSaveAll,
                        icon: Icons.save_outlined,
                        isLoading: widget.isWorking,
                        onPressed: widget.isWorking ? null : _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final chemicalResults = <ChemicalAnalysisResultDraft>[];
    final physicalResults = <PhysicalAnalysisResultDraft>[];

    for (final parameter in widget.workspace.chemicalParameters) {
      final text = _chemicalControllers[parameter.id]!.text.trim();
      if (text.isEmpty) {
        continue;
      }
      final value = double.tryParse(text);
      if (value == null) {
        setState(() => _validationMessage = l10n.rawAnalysisInvalidValue);
        return;
      }
      chemicalResults.add(
        ChemicalAnalysisResultDraft(parameterId: parameter.id, value: value),
      );
    }

    for (final parameter in widget.workspace.physicalParameters) {
      final value = _physicalControllers[parameter.id]!.text.trim();
      if (value.isNotEmpty) {
        physicalResults.add(
          PhysicalAnalysisResultDraft(parameterId: parameter.id, value: value),
        );
      }
    }

    if (chemicalResults.isEmpty && physicalResults.isEmpty) {
      setState(() => _validationMessage = l10n.rawAnalysisAtLeastOne);
      return;
    }

    setState(() => _validationMessage = null);
    final succeeded = await widget.onSave(
      RawMaterialAnalysisSubmission(
        chemicalResults: chemicalResults,
        physicalResults: physicalResults,
      ),
    );
    if (succeeded && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _AnalysisSummary extends StatelessWidget {
  final RawMaterialAnalysisWorkspace workspace;

  const _AnalysisSummary({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 4.h,
        children: [
          Text(l10n.rawAnalysisResultsSummary(workspace.totalParameters)),
          Text(
            '${l10n.rawWorkflowSupplierWeight}: '
            '${workspace.supplierWeight} ${workspace.unit ?? ''}',
          ),
          Text(
            '${l10n.rawWorkflowWarehouse}: '
            '${workspace.warehouseName ?? '-'}',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19.r, color: PernitColors.primary),
        SizedBox(width: 7.w),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _ChemicalParameterField extends StatelessWidget {
  final ChemicalAnalysisParameter parameter;
  final TextEditingController controller;
  final bool enabled;

  const _ChemicalParameterField({
    required this.parameter,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sopLabel = [
      parameter.sopDocumentNumber,
      parameter.sopName,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' — ');

    return _CompactParameterField(
      title: parameter.name,
      subtitle: sopLabel.isEmpty
          ? l10n.rawAnalysisSopNotConfigured
          : '${l10n.rawAnalysisSop}: $sopLabel',
      detail: parameter.normalMin != null && parameter.normalMax != null
          ? l10n.rawAnalysisNormalRange(
              parameter.normalMin.toString(),
              parameter.normalMax.toString(),
            )
          : null,
      trailing: parameter.isWithinRange == null
          ? null
          : Icon(
              parameter.isWithinRange!
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 20.r,
              color: parameter.isWithinRange!
                  ? PernitColors.success
                  : PernitColors.danger,
            ),
      field: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
        ],
        decoration: InputDecoration(
          isDense: true,
          labelText: l10n.rawAnalysisValue,
          suffixText: parameter.unit,
        ),
      ),
    );
  }
}

class _PhysicalParameterField extends StatelessWidget {
  final PhysicalAnalysisParameter parameter;
  final TextEditingController controller;
  final bool enabled;

  const _PhysicalParameterField({
    required this.parameter,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = [
      if (parameter.reference != null)
        l10n.rawAnalysisReference(parameter.reference!),
      if (parameter.rejectedReference != null)
        l10n.rawAnalysisRejectReference(parameter.rejectedReference!),
    ];

    return _CompactParameterField(
      title: parameter.name,
      detail: details.isEmpty ? null : details.join(' • '),
      field: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          isDense: true,
          labelText: l10n.rawAnalysisValue,
        ),
      ),
    );
  }
}

class _CompactParameterField extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? detail;
  final Widget? trailing;
  final Widget field;

  const _CompactParameterField({
    required this.title,
    this.subtitle,
    this.detail,
    this.trailing,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(9.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (detail != null) ...[
            SizedBox(height: 2.h),
            Text(
              detail!,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: PernitColors.textMuted),
            ),
          ],
          SizedBox(height: 6.h),
          field,
        ],
      ),
    );
  }
}
