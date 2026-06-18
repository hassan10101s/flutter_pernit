import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../../../design_system/widgets/pernit_icon_button.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import 'raw_material_entry_copy.dart';

class RawMaterialEntryForm extends StatefulWidget {
  final RawMaterialEntryLookups lookups;
  final bool isSubmitting;
  final bool isRefreshingLookups;
  final VoidCallback onRefreshLookups;
  final ValueChanged<RawMaterialEntryDraft> onSubmit;

  const RawMaterialEntryForm({
    super.key,
    required this.lookups,
    required this.isSubmitting,
    required this.isRefreshingLookups,
    required this.onRefreshLookups,
    required this.onSubmit,
  });

  @override
  State<RawMaterialEntryForm> createState() => _RawMaterialEntryFormState();
}

class _RawMaterialEntryFormState extends State<RawMaterialEntryForm> {
  final _quantityController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _lotController = TextEditingController();
  final _expiryController = TextEditingController();

  LookupOption? _rawMaterial;
  LookupOption? _purchaseOrderDetail;
  LookupOption? _warehouse;
  String? _driverName;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    _vehicleController.dispose();
    _lotController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = RawMaterialEntryCopy.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: PernitColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  copy.entryForm,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: PernitColors.textStrong,
                    fontWeight: PernitFontWeights.bold,
                  ),
                ),
              ),
              PernitIconButton(
                icon: Icons.sync_rounded,
                tooltip: copy.refreshLookups,
                onPressed: widget.isRefreshingLookups
                    ? null
                    : widget.onRefreshLookups,
                size: 40.r,
                iconSize: 22.r,
                backgroundColor: PernitColors.background,
                borderColor: PernitColors.border,
                foregroundColor: widget.isRefreshingLookups
                    ? Colors.transparent
                    : PernitColors.textInk,
                child: widget.isRefreshingLookups
                    ? SizedBox.square(
                        dimension: 18.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ],
          ),
          verticalSpace(12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              final spacing = 12.w;
              final width =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 12.h,
                children: [
                  _fieldBox(
                    width,
                    _LookupAutocompleteField(
                      label: copy.rawMaterial,
                      hint: copy.rawMaterialHint,
                      icon: Icons.category_outlined,
                      options: widget.lookups.rawMaterials,
                      onSelected: (option) {
                        setState(() {
                          _rawMaterial = option;
                          _errorMessage = null;
                        });
                      },
                    ),
                  ),
                  _fieldBox(
                    width,
                    _LookupAutocompleteField(
                      label: copy.purchaseOrderDetail,
                      hint: copy.purchaseOrderDetailHint,
                      icon: Icons.receipt_long_outlined,
                      options: widget.lookups.purchaseOrderDetails,
                      onSelected: _selectPurchaseOrderDetail,
                    ),
                  ),
                  _fieldBox(
                    width,
                    _LookupAutocompleteField(
                      label: copy.warehouse,
                      hint: copy.warehouseHint,
                      icon: Icons.warehouse_outlined,
                      options: widget.lookups.warehouses,
                      onSelected: (option) {
                        setState(() {
                          _warehouse = option;
                        });
                      },
                    ),
                  ),
                  _fieldBox(
                    width,
                    _LookupAutocompleteField(
                      label: copy.driver,
                      hint: copy.driverHint,
                      icon: Icons.person_outline,
                      options: widget.lookups.drivers,
                      onTextChanged: (value) => _driverName = value,
                      onSelected: (option) {
                        setState(() {
                          _driverName = option.label;
                        });
                      },
                    ),
                  ),
                  _fieldBox(
                    width,
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: copy.quantity,
                        hintText: copy.quantityHint,
                        prefixIcon: const Icon(Icons.scale_outlined),
                      ),
                    ),
                  ),
                  _fieldBox(
                    width,
                    TextFormField(
                      controller: _vehicleController,
                      decoration: InputDecoration(
                        labelText: copy.vehicleNo,
                        hintText: copy.vehicleNoHint,
                        prefixIcon: const Icon(Icons.local_shipping_outlined),
                      ),
                    ),
                  ),
                  _fieldBox(
                    width,
                    TextFormField(
                      controller: _lotController,
                      decoration: InputDecoration(
                        labelText: copy.lotNo,
                        hintText: copy.lotNoHint,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                      ),
                    ),
                  ),
                  _fieldBox(
                    width,
                    TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: copy.expiryDate,
                        hintText: copy.expiryDateHint,
                        prefixIcon: const Icon(Icons.event_outlined),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_errorMessage != null) ...[
            verticalSpace(10),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.danger),
            ),
          ],
          verticalSpace(14),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 260.w),
              child: PernitButton(
                label: copy.submit,
                icon: Icons.add_task_outlined,
                isLoading: widget.isSubmitting,
                onPressed: widget.isSubmitting ? null : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldBox(double width, Widget child) {
    return SizedBox(width: width, child: child);
  }

  void _selectPurchaseOrderDetail(LookupOption option) {
    setState(() {
      _purchaseOrderDetail = option;
      _errorMessage = null;

      final rawMaterialName = option.rawMaterialName;
      if (rawMaterialName == null) {
        return;
      }

      final matchingRawMaterial = widget.lookups.rawMaterials
          .where(
            (candidate) =>
                candidate.label.toLowerCase().contains(
                  rawMaterialName.toLowerCase(),
                ) ||
                rawMaterialName.toLowerCase().contains(
                  candidate.label.toLowerCase(),
                ),
          )
          .firstOrNull;
      if (matchingRawMaterial != null) {
        _rawMaterial = matchingRawMaterial;
      }
    });
  }

  void _submit() {
    final copy = RawMaterialEntryCopy.of(context);
    final quantity = double.tryParse(_quantityController.text.trim());
    if (_rawMaterial == null || quantity == null || quantity <= 0) {
      setState(() => _errorMessage = copy.requiredFieldsMessage);
      return;
    }

    final expiryText = _expiryController.text.trim();
    final expiryDate = expiryText.isEmpty
        ? null
        : DateTime.tryParse(expiryText);
    if (expiryText.isNotEmpty && expiryDate == null) {
      setState(() => _errorMessage = copy.invalidDateMessage);
      return;
    }

    setState(() => _errorMessage = null);
    widget.onSubmit(
      RawMaterialEntryDraft(
        rawMaterialId: _rawMaterial!.id,
        purchaseOrderDetailId: _purchaseOrderDetail?.id,
        warehouseId: _warehouse?.id,
        quantityFromSupplier: quantity,
        vehicleNo: _blankAsNull(_vehicleController.text),
        driverName: _blankAsNull(_driverName),
        lotNo: _blankAsNull(_lotController.text),
        expiryDate: expiryDate,
      ),
    );
  }

  String? _blankAsNull(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}

class _LookupAutocompleteField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<LookupOption> options;
  final ValueChanged<LookupOption> onSelected;
  final ValueChanged<String>? onTextChanged;

  const _LookupAutocompleteField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.options,
    required this.onSelected,
    this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<LookupOption>(
      displayStringForOption: (option) => option.label,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        onTextChanged?.call(value.text);
        if (query.isEmpty) {
          return options;
        }
        return options.where((option) {
          return option.label.toLowerCase().contains(query) ||
              (option.subtitle?.toLowerCase().contains(query) ?? false);
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onFieldSubmitted: (_) => onFieldSubmitted(),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, visibleOptions) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(8.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 240.h, maxWidth: 360.w),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: visibleOptions.length,
                itemBuilder: (context, index) {
                  final option = visibleOptions.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option.label),
                    subtitle: option.subtitle == null
                        ? null
                        : Text(option.subtitle!),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
