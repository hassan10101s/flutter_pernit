import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../bloc/raw_material_inventory_cubit.dart';
import '../bloc/raw_material_inventory_state.dart';
import '../widgets/raw_material_workflow_card.dart';

class RawMaterialInventoryScreen extends StatelessWidget {
  const RawMaterialInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RawMaterialInventoryCubit>()..load(),
      child: const _RawMaterialInventoryView(),
    );
  }
}

class _RawMaterialInventoryView extends StatefulWidget {
  const _RawMaterialInventoryView();

  @override
  State<_RawMaterialInventoryView> createState() =>
      _RawMaterialInventoryViewState();
}

class _RawMaterialInventoryViewState extends State<_RawMaterialInventoryView> {
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
            _InventoryTabs(
              selectedIndex: _selectedTab,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _countLabel(l10n, state),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PernitColors.textMuted,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.rawWorkflowRefresh,
                  onPressed: state is RawMaterialInventoryLoading
                      ? null
                      : cubit.load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (state is RawMaterialInventoryLoading &&
                state.entries.isEmpty &&
                state.stockItems.isEmpty &&
                state.productStock.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              switch (_selectedTab) {
                0 => _CurrentStockTab(state: state, cubit: cubit),
                1 => _RawMaterialReceivingTab(state: state, cubit: cubit),
                _ => _FinishedProductStockTab(state: state, cubit: cubit),
              },
          ],
        );
      },
    );
  }

  String _countLabel(AppLocalizations l10n, RawMaterialInventoryState state) {
    return switch (_selectedTab) {
      0 => l10n.rawInventoryCurrentCount(state.stockTotalCount),
      1 => l10n.rawInventoryQueueCount(state.totalCount),
      _ => l10n.rawInventoryProductCount(state.productStock.length),
    };
  }
}

class _InventoryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _InventoryTabs({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.inventory_2_outlined, l10n.rawInventoryCurrentTab),
      (Icons.scale_outlined, l10n.rawInventoryReceivingTab),
      (Icons.add_box_outlined, l10n.rawInventoryFinishedProductTab),
    ];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(9.r),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 3.w,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? PernitColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].$1,
                        size: 19.r,
                        color: selectedIndex == index
                            ? Colors.white
                            : PernitColors.textMuted,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        items[index].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selectedIndex == index
                              ? Colors.white
                              : PernitColors.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index < items.length - 1) SizedBox(width: 4.w),
          ],
        ],
      ),
    );
  }
}

class _CurrentStockTab extends StatelessWidget {
  final RawMaterialInventoryState state;
  final RawMaterialInventoryCubit cubit;

  const _CurrentStockTab({required this.state, required this.cubit});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final warehouse in byWarehouse.entries) ...[
          _WarehouseStockCard(
            warehouseName: warehouse.key,
            items: warehouse.value,
          ),
          SizedBox(height: 10.h),
        ],
        if (state.stockHasNextPage)
          PernitButton(
            label: l10n.rawWorkflowLoadMore,
            icon: Icons.expand_more_rounded,
            fullWidth: false,
            isLoading:
                state is RawMaterialInventoryLoadingMore && state.loadingStock,
            onPressed: state is RawMaterialInventoryLoadingMore
                ? null
                : cubit.loadMoreStock,
          ),
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
                Text(
                  l10n.rawInventoryReserved(
                    '${item.reservedQuantity} ${item.unitName ?? ''}',
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${item.availableQuantity} ${item.unitName ?? ''}',
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

    return Column(
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
          PernitButton(
            label: l10n.rawWorkflowLoadMore,
            icon: Icons.expand_more_rounded,
            fullWidth: false,
            isLoading:
                state is RawMaterialInventoryLoadingMore && !state.loadingStock,
            onPressed: state is RawMaterialInventoryLoadingMore
                ? null
                : cubit.loadMoreQueue,
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
            textDirection: TextDirection.ltr,
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

class _FinishedProductStockTab extends StatefulWidget {
  final RawMaterialInventoryState state;
  final RawMaterialInventoryCubit cubit;

  const _FinishedProductStockTab({required this.state, required this.cubit});

  @override
  State<_FinishedProductStockTab> createState() =>
      _FinishedProductStockTabState();
}

class _FinishedProductStockTabState extends State<_FinishedProductStockTab> {
  final _quantityController = TextEditingController();
  int? _productId;
  int? _warehouseId;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.state;
    final isSubmitting =
        state is RawMaterialInventoryWorking &&
        state.action == RawMaterialInventoryAction.addingProductStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: PernitColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: PernitColors.borderMuted),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.rawInventoryAddProductTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 10.h),
              DropdownButtonFormField<int>(
                initialValue: _productId,
                items: [
                  for (final product in state.products)
                    DropdownMenuItem(
                      value: product.id,
                      child: Text(
                        product.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: isSubmitting
                    ? null
                    : (value) => setState(() {
                        _productId = value;
                        _error = null;
                      }),
                decoration: InputDecoration(
                  labelText: l10n.rawInventoryProduct,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<int>(
                initialValue: _warehouseId,
                items: [
                  for (final warehouse in state.warehouses)
                    DropdownMenuItem(
                      value: warehouse.id,
                      child: Text(
                        warehouse.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: isSubmitting
                    ? null
                    : (value) => setState(() {
                        _warehouseId = value;
                        _error = null;
                      }),
                decoration: InputDecoration(
                  labelText: l10n.rawWorkflowWarehouse,
                  prefixIcon: const Icon(Icons.warehouse_outlined),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _quantityController,
                enabled: !isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.rawInventoryProductQuantity,
                  prefixIcon: const Icon(Icons.numbers_outlined),
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: 6.h),
                Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: PernitColors.danger),
                ),
              ],
              SizedBox(height: 10.h),
              PernitButton(
                label: l10n.rawInventoryAddProduct,
                icon: Icons.add_box_outlined,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (state.productStock.isEmpty)
          _InventoryEmptyState(message: l10n.rawInventoryProductEmpty)
        else
          for (final item in state.productStock) ...[
            _ProductStockCard(item: item),
            SizedBox(height: 7.h),
          ],
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final quantity = double.tryParse(_quantityController.text.trim());
    if (_productId == null ||
        _warehouseId == null ||
        quantity == null ||
        quantity <= 0) {
      setState(() => _error = l10n.rawInventoryProductRequired);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawInventoryAddProductTitle),
        content: Text(l10n.rawInventoryAddProductConfirm),
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
    final succeeded = await widget.cubit.addFinishedProductStock(
      ProductStockDraft(
        productId: _productId!,
        warehouseId: _warehouseId!,
        quantity: quantity,
      ),
    );
    if (succeeded && mounted) {
      _quantityController.clear();
      setState(() {
        _productId = null;
        _warehouseId = null;
        _error = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.rawInventoryProductSuccess)));
    }
  }
}

class _ProductStockCard extends StatelessWidget {
  final ProductStockItem item;

  const _ProductStockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_outlined, color: PernitColors.primary),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName),
                Text(
                  item.warehouseName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${item.availableQuantity} ${item.unitName ?? ''}',
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
