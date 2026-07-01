import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/export/inventory_pdf_exporter.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_bottom_segmented_bar.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../bloc/raw_material_inventory_cubit.dart';
import '../bloc/raw_material_inventory_state.dart';
import '../widgets/raw_material_workflow_card.dart';
import 'product_inventory_screen.dart';

class RawMaterialInventoryScreen extends StatelessWidget {
  const RawMaterialInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RawMaterialInventoryCubit>()..load(),
      child: const _RawMaterialContentView(),
    );
  }
}

class _RawMaterialContentView extends StatefulWidget {
  const _RawMaterialContentView();

  @override
  State<_RawMaterialContentView> createState() =>
      _RawMaterialContentViewState();
}

class _RawMaterialContentViewState extends State<_RawMaterialContentView> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<RawMaterialInventoryCubit, RawMaterialInventoryState>(
      listener: (context, state) {
        if (state is RawMaterialInventoryError) {
          final message = FailureMessageLocalizer.messageFor(
            l10n,
            state.failure.messageKey,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<RawMaterialInventoryCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InventoryHeader(
              state: state,
              onRefresh: cubit.load,
              onPdf: () => _exportRawPdf(context, state, l10n),
            ),
            Expanded(
              child: switch (state) {
                RawMaterialInventoryLoading(:final entries, :final stockItems)
                    when entries.isEmpty && stockItems.isEmpty =>
                  const Center(child: CircularProgressIndicator()),
                _ =>
                  _selectedTab == 0
                      ? _CurrentStockTab(state: state)
                      : _RawMaterialReceivingTab(state: state, cubit: cubit),
              },
            ),
            _RawBottomBar(
              selectedIndex: _selectedTab,
              onSelected: (index) async {
                if (index == 2) {
                  final result = await Navigator.of(context)
                      .push<ProductReturnArgs>(
                        MaterialPageRoute(
                          builder: (_) => const ProductInventoryScreen(),
                        ),
                      );
                  if (result != null && mounted && result.tabIndex < 2) {
                    setState(() => _selectedTab = result.tabIndex);
                  }
                } else {
                  setState(() => _selectedTab = index);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportRawPdf(
    BuildContext context,
    RawMaterialInventoryState state,
    AppLocalizations l10n,
  ) async {
    final items = state.stockItems
        .map(
          (item) => PdfInventoryRow(
            name: item.rawMaterialName,
            warehouse: item.warehouseName,
            quantity: item.quantity.toStringAsFixed(3),
            available: item.availableQuantity.toStringAsFixed(3),
            reserved: item.reservedQuantity.toStringAsFixed(3),
            unit: item.unitName ?? '',
          ),
        )
        .toList();
    try {
      ByteData? fontData;
      try {
        fontData = await DefaultAssetBundle.of(
          context,
        ).load('assets/fonts/Cairo-Bold.ttf');
      } catch (_) {
        fontData = null;
      }
      final bytes = await InventoryPdfExporter.generateReport(
        labels: PdfLabels(
          title: l10n.menuInventory,
          item: l10n.inventoryPdfItem,
          warehouse: l10n.inventoryPdfWarehouse,
          total: l10n.inventoryPdfTotal,
          available: l10n.inventoryPdfAvailable,
          reserved: l10n.inventoryPdfReserved,
          unit: l10n.inventoryPdfUnit,
          lastLoaded: l10n.inventoryPdfLastLoaded,
          items: l10n.inventoryPdfItems,
          truncatedNote: state.stockWasTruncated
              ? l10n.inventoryPdfTruncatedNote(state.stockTotalCount)
              : null,
        ),
        lastLoadedAt: state.lastLoadedAt,
        itemCount: items.length,
        rows: items,
        fontData: fontData,
        isRtl: true,
      );
      if (context.mounted) {
        await InventoryPdfExporter.sharePdf(
          bytes,
          filename: 'raw_material_inventory.pdf',
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.inventoryPdfExportError)));
      }
    }
  }
}

class _RawBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _RawBottomBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PernitBottomSegmentedBar(
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      items: [
        PernitBottomSegmentedBarItem(
          icon: Icons.inventory_2_outlined,
          label: l10n.rawInventoryCurrentTab,
        ),
        PernitBottomSegmentedBarItem(
          icon: Icons.scale_outlined,
          label: l10n.rawInventoryReceivingTab,
        ),
        PernitBottomSegmentedBarItem(
          icon: Icons.add_box_outlined,
          label: l10n.rawInventoryFinishedProductTab,
        ),
      ],
    );
  }
}

class _InventoryHeader extends StatelessWidget {
  final RawMaterialInventoryState state;
  final VoidCallback onRefresh;
  final VoidCallback onPdf;

  const _InventoryHeader({
    required this.state,
    required this.onRefresh,
    required this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = state.stockTotalCount;
    final loadedStr = state.lastLoadedAt != null
        ? DateFormat('HH:mm').format(state.lastLoadedAt!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.stockWasTruncated)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              l10n.inventoryTruncatedWarning(state.stockTotalCount),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: PernitColors.warning),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.rawInventoryCurrentCount(count),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ),
              if (loadedStr != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Text(
                    '${l10n.inventoryLastLoaded}: $loadedStr',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PernitColors.textSubtle,
                    ),
                  ),
                ),
              IconButton(
                tooltip: l10n.inventoryDownloadPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                onPressed: state is RawMaterialInventoryLoading ? null : onPdf,
              ),
              IconButton.filledTonal(
                tooltip: l10n.rawWorkflowRefresh,
                onPressed: state is RawMaterialInventoryLoading
                    ? null
                    : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentStockTab extends StatelessWidget {
  final RawMaterialInventoryState state;

  const _CurrentStockTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.stockItems.isEmpty) {
      return _InventoryEmptyState(message: l10n.rawInventoryCurrentEmpty);
    }

    final byWarehouse = <String, List<RawMaterialStockItem>>{};
    for (final item in state.stockItems) {
      byWarehouse.putIfAbsent(item.warehouseName, () => []).add(item);
    }

    return ListView(
      children: [
        for (final warehouse in byWarehouse.entries) ...[
          _WarehouseStockCard(
            warehouseName: warehouse.key,
            items: warehouse.value,
          ),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _WarehouseStockCard extends StatelessWidget {
  final String warehouseName;
  final List<RawMaterialStockItem> items;

  const _WarehouseStockCard({required this.warehouseName, required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                const Icon(
                  Icons.warehouse_outlined,
                  color: PernitColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    warehouseName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  l10n.rawInventoryItemsCount(items.length),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (var index = 0; index < items.length; index++) ...[
            _StockRow(item: items[index]),
            if (index < items.length - 1)
              const Divider(height: 1, indent: 12, endIndent: 12),
          ],
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final RawMaterialStockItem item;

  const _StockRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.rawMaterialName),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _DetailChip(
                      label:
                          '${l10n.inventoryTotal}: ${item.quantity.toStringAsFixed(3)}',
                    ),
                    SizedBox(width: 6.w),
                    _DetailChip(
                      label:
                          '${l10n.inventoryAvailable}: ${item.availableQuantity.toStringAsFixed(3)}',
                      color: PernitColors.success,
                    ),
                    SizedBox(width: 6.w),
                    _DetailChip(
                      label:
                          '${l10n.inventoryReserved}: ${item.reservedQuantity.toStringAsFixed(3)}',
                      color: PernitColors.warning,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  item.unitName ?? '',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Text(
              '${item.availableQuantity.toStringAsFixed(3)} ${item.unitName ?? ''}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: PernitColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _DetailChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: (color ?? PernitColors.textSubtle).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 9.sp,
          color: color ?? PernitColors.textSubtle,
        ),
      ),
    );
  }
}

class _RawMaterialReceivingTab extends StatelessWidget {
  final RawMaterialInventoryState state;
  final RawMaterialInventoryCubit cubit;

  const _RawMaterialReceivingTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.entries.isEmpty) {
      return _InventoryEmptyState(message: l10n.rawInventoryEmpty);
    }

    return ListView(
      children: [
        for (final entry in state.entries) ...[
          RawMaterialWorkflowCard(
            entry: entry,
            statusLabel: l10n.rawQualityAwaitingInventory,
            statusTone: PernitStatusBadgeTone.success,
            actionLabel: l10n.rawInventoryEnterStock,
            actionIcon: Icons.scale_outlined,
            isWorking:
                state is RawMaterialInventoryWorking &&
                state.action == RawMaterialInventoryAction.recordingWeight &&
                state.activeBatchId == entry.id,
            onAction: () => _openWeightSheet(context, entry),
          ),
          SizedBox(height: 10.h),
        ],
        if (state.hasNextPage)
          Center(
            child: PernitButton(
              label: l10n.rawWorkflowLoadMore,
              icon: Icons.expand_more_rounded,
              fullWidth: false,
              isLoading: state is RawMaterialInventoryLoadingMore,
              onPressed: state is RawMaterialInventoryLoadingMore
                  ? null
                  : cubit.loadMoreQueue,
            ),
          ),
      ],
    );
  }

  Future<void> _openWeightSheet(
    BuildContext context,
    RawMaterialEntry entry,
  ) async {
    final succeeded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PernitColors.surface,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ActualWeightSheet(entry: entry),
      ),
    );
    if (succeeded == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.rawInventorySuccess),
        ),
      );
    }
  }
}

class _ActualWeightSheet extends StatefulWidget {
  final RawMaterialEntry entry;

  const _ActualWeightSheet({required this.entry});

  @override
  State<_ActualWeightSheet> createState() => _ActualWeightSheetState();
}

class _ActualWeightSheetState extends State<_ActualWeightSheet> {
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _scaleImage;
  Uint8List? _scaleImageBytes;
  double? _actualWeight;
  String? _error;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<RawMaterialInventoryCubit, RawMaterialInventoryState>(
      builder: (context, state) {
        final isSubmitting =
            state is RawMaterialInventoryWorking &&
            state.action == RawMaterialInventoryAction.recordingWeight &&
            state.activeBatchId == widget.entry.id;
        final variance = _actualWeight == null
            ? null
            : _actualWeight! - widget.entry.quantityFromSupplier;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            16.h + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.rawInventoryActualWeight,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  '${widget.entry.rawMaterialName}${l10n.separatorDot}'
                  '${l10n.rawWorkflowBatch(widget.entry.id)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
                SizedBox(height: 12.h),
                _SupplierWeightTile(entry: widget.entry),
                SizedBox(height: 10.h),
                TextField(
                  controller: _weightController,
                  enabled: !isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,6}'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _actualWeight = double.tryParse(value.trim());
                      _error = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: l10n.rawInventoryActualWeight,
                    prefixIcon: const Icon(Icons.scale_outlined),
                    suffixText: widget.entry.unitName,
                  ),
                ),
                if (variance != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    l10n.rawInventoryVariance(
                      '${variance >= 0 ? '+' : ''}'
                      '${variance.toStringAsFixed(3)} '
                      '${widget.entry.unitName ?? ''}',
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: variance.abs() > 0
                          ? PernitColors.warning
                          : PernitColors.textMuted,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                _ScaleImagePicker(
                  image: _scaleImage,
                  bytes: _scaleImageBytes,
                  enabled: !isSubmitting,
                  onPick: _chooseImageSource,
                ),
                if (_error != null) ...[
                  SizedBox(height: 7.h),
                  Text(
                    _error!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: PernitColors.danger),
                  ),
                ],
                SizedBox(height: 14.h),
                PernitButton(
                  label: l10n.rawInventoryEnterStock,
                  icon: Icons.inventory_2_outlined,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _chooseImageSource() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.rawInventoryTakePhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.rawInventoryChoosePhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) {
      return;
    }
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (image == null || !mounted) {
      return;
    }
    final bytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _scaleImage = image;
      _scaleImageBytes = bytes;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final actualWeight = double.tryParse(_weightController.text.trim());
    if (actualWeight == null || actualWeight <= 0) {
      setState(() => _error = l10n.rawInventoryWeightRequired);
      return;
    }
    if (_scaleImage == null) {
      setState(() => _error = l10n.rawInventoryImageRequired);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawInventoryActualWeight),
        content: Text(l10n.rawInventoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.screenCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final succeeded = await context
        .read<RawMaterialInventoryCubit>()
        .recordActualWeight(
          batchId: widget.entry.id,
          measuredQuantity: actualWeight,
          measuredImagePath: _scaleImage!.path,
        );
    if (succeeded && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _SupplierWeightTile extends StatelessWidget {
  final RawMaterialEntry entry;

  const _SupplierWeightTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(child: Text(l10n.rawWorkflowSupplierWeight)),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Text(
              '${entry.quantityFromSupplier} ${entry.unitName ?? ''}',
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleImagePicker extends StatelessWidget {
  final XFile? image;
  final Uint8List? bytes;
  final bool enabled;
  final VoidCallback onPick;

  const _ScaleImagePicker({
    required this.image,
    required this.bytes,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: enabled ? onPick : null,
      borderRadius: BorderRadius.circular(11.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: PernitColors.surface,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(
            color: image == null ? PernitColors.warning : PernitColors.success,
          ),
        ),
        child: Row(
          children: [
            if (bytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.memory(
                  bytes!,
                  width: 52.r,
                  height: 52.r,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: PernitColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.add_a_photo_outlined),
              ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.rawInventoryScaleImage),
                  Text(
                    image?.name ?? l10n.rawInventoryScaleImageHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PernitColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _InventoryEmptyState extends StatelessWidget {
  final String message;

  const _InventoryEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 38.r,
            color: PernitColors.textMuted,
          ),
          SizedBox(height: 8.h),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
