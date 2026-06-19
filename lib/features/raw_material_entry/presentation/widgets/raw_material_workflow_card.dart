import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/raw_material_entry.dart';

class RawMaterialWorkflowCard extends StatelessWidget {
  final RawMaterialEntry entry;
  final String statusLabel;
  final PernitStatusBadgeTone statusTone;
  final String? actionLabel;
  final IconData? actionIcon;
  final bool isWorking;
  final VoidCallback? onAction;

  const RawMaterialWorkflowCard({
    super.key,
    required this.entry,
    required this.statusLabel,
    required this.statusTone,
    this.actionLabel,
    this.actionIcon,
    this.isWorking = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PernitColors.borderMuted),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: PernitColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: PernitColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.rawMaterialName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: PernitFontWeights.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        l10n.rawWorkflowBatch(entry.id),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              PernitStatusBadge(label: statusLabel, tone: statusTone),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _WorkflowFact(
                icon: Icons.scale_outlined,
                label: l10n.rawWorkflowSupplierWeight,
                value: _quantity(entry.quantityFromSupplier, entry.unitName),
              ),
              _WorkflowFact(
                icon: Icons.warehouse_outlined,
                label: l10n.rawWorkflowWarehouse,
                value: entry.warehouseName ?? '-',
              ),
              _WorkflowFact(
                icon: Icons.local_shipping_outlined,
                label: entry.supplierName ?? '-',
                value: entry.vehicleNo ?? '-',
              ),
            ],
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 14.h),
            PernitButton(
              label: actionLabel!,
              icon: actionIcon,
              isLoading: isWorking,
              onPressed: isWorking ? null : onAction,
            ),
          ],
        ],
      ),
    );
  }

  String _quantity(double value, String? unit) {
    final formatted = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(3);
    return unit == null || unit.trim().isEmpty ? formatted : '$formatted $unit';
  }
}

class _WorkflowFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WorkflowFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 120.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17.r, color: PernitColors.textMuted),
          SizedBox(width: 7.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PernitColors.textStrong,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
