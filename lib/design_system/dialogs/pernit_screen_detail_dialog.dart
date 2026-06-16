import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/helpers/spacing.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/screen_records/pernit_screen_record.dart';
import '../tokens/pernit_colors.dart';
import '../tokens/pernit_font_weights.dart';

export '../../core/screen_records/pernit_screen_record.dart';

class PernitScreenDetailItem {
  final IconData icon;
  final String label;
  final String endpoint;
  final List<PernitScreenRecord> records;

  const PernitScreenDetailItem({
    required this.icon,
    required this.label,
    required this.endpoint,
    required this.records,
  });
}

class PernitScreenDetailDialog extends StatefulWidget {
  final PernitScreenDetailItem item;
  final List<PernitScreenRecord> records;
  final ValueChanged<PernitScreenRecord> onAdd;
  final void Function(int index, PernitScreenRecord record) onEdit;
  final ValueChanged<int> onDelete;

  const PernitScreenDetailDialog({
    super.key,
    required this.item,
    required this.records,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PernitScreenDetailDialog> createState() =>
      _PernitScreenDetailDialogState();
}

class _PernitScreenDetailDialogState extends State<PernitScreenDetailDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      title: Row(
        children: [
          Icon(widget.item.icon, color: PernitColors.primary, size: 24.r),
          horizontalSpace(12),
          Expanded(
            child: Text(
              widget.item.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: PernitColors.textStrong,
                fontWeight: PernitFontWeights.bold,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720.w,
          maxHeight: size.height * 0.72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.screenDialogSubtitle(widget.item.label),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
            ),
            verticalSpace(14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.screenRecordsTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PernitColors.textStrong,
                      fontWeight: PernitFontWeights.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _openRecordForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.screenAddAction),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(8),
            Flexible(
              child: widget.records.isEmpty
                  ? Center(
                      child: Text(
                        l10n.screenNoRecords,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < widget.records.length;
                            index++
                          ) ...[
                            _RecordListTile(
                              record: widget.records[index],
                              onEdit: () => _openRecordForm(
                                context,
                                record: widget.records[index],
                                index: index,
                              ),
                              onDelete: () => _confirmDelete(context, index),
                            ),
                            if (index < widget.records.length - 1)
                              verticalSpace(8),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.screenCloseAction),
        ),
      ],
    );
  }

  Future<void> _openRecordForm(
    BuildContext context, {
    PernitScreenRecord? record,
    int? index,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: record?.title ?? '');
    final fieldKeys = _formFieldKeys(record);
    final fieldControllers = {
      for (final key in fieldKeys)
        key: TextEditingController(text: record?.fields[key] ?? ''),
    };

    final saved = await showDialog<PernitScreenRecord>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          record == null
              ? l10n.screenAddDialogTitle(widget.item.label)
              : l10n.screenEditDialogTitle(widget.item.label),
        ),
        content: SizedBox(
          width: 420.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.screenNameField),
              ),
              for (final entry in fieldControllers.entries) ...[
                verticalSpace(10),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: entry.key),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.screenCancelAction),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(
                PernitScreenRecord.api(
                  title: titleController.text.trim().isEmpty
                      ? widget.item.label
                      : titleController.text.trim(),
                  fields: {
                    for (final entry in fieldControllers.entries)
                      entry.key: entry.value.text.trim(),
                  },
                ),
              );
            },
            child: Text(l10n.screenSaveAction),
          ),
        ],
      ),
    );

    titleController.dispose();
    for (final controller in fieldControllers.values) {
      controller.dispose();
    }

    if (saved == null || !mounted) {
      return;
    }

    if (index == null) {
      widget.onAdd(saved);
    } else {
      widget.onEdit(index, saved);
    }
  }

  List<String> _formFieldKeys(PernitScreenRecord? record) {
    final keys = record?.fields.keys.toList();
    if (keys != null && keys.isNotEmpty) {
      return keys;
    }

    if (widget.records.isNotEmpty) {
      return widget.records.first.fields.keys.toList();
    }

    if (widget.item.records.isNotEmpty) {
      return widget.item.records.first.fields.keys.toList();
    }

    return const [];
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final l10n = AppLocalizations.of(context)!;
    final record = widget.records[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.screenDeleteConfirmTitle),
        content: Text(l10n.screenDeleteConfirmMessage(record.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.screenCancelAction),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.screenDeleteAction),
            style: FilledButton.styleFrom(
              backgroundColor: PernitColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    widget.onDelete(index);
  }
}

class _RecordListTile extends StatelessWidget {
  final PernitScreenRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordListTile({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: PernitColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PernitColors.textStrong,
                    fontWeight: PernitFontWeights.bold,
                  ),
                ),
                verticalSpace(6),
                for (final entry in record.fields.entries)
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.h),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          horizontalSpace(8),
          Column(
            children: [
              Tooltip(
                message: l10n.screenEditAction,
                child: IconButton.filledTonal(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
              verticalSpace(4),
              Tooltip(
                message: l10n.screenDeleteAction,
                child: IconButton.filledTonal(
                  onPressed: onDelete,
                  color: PernitColors.danger,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
