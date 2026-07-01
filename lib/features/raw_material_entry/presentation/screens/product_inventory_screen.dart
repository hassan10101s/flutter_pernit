import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/export/inventory_pdf_exporter.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_bottom_segmented_bar.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../bloc/product_inventory_cubit.dart';
import '../bloc/product_inventory_state.dart';

/// Pop result indicating which tab to open in the raw material screen.
class ProductReturnArgs {
  final int tabIndex;
  const ProductReturnArgs(this.tabIndex);
}

class ProductInventoryScreen extends StatefulWidget {
  const ProductInventoryScreen({super.key});

  @override
  State<ProductInventoryScreen> createState() => _ProductInventoryScreenState();
}

class _ProductInventoryScreenState extends State<ProductInventoryScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.rawInventoryFinishedProductTab,
        ),
      ),
      body: BlocProvider(
        create: (_) => sl<ProductInventoryCubit>()..load(),
        child: BlocConsumer<ProductInventoryCubit, ProductInventoryState>(
          listener: (context, state) {
            if (state is ProductInventoryError) {
              final message = FailureMessageLocalizer.messageFor(
                AppLocalizations.of(context)!,
                state.failure.messageKey,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            final cubit = context.read<ProductInventoryCubit>();
            final l10n = AppLocalizations.of(context)!;
            final isSubmitting =
                state is ProductInventoryWorking &&
                state.action == ProductInventoryAction.addingProductStock;

            if (state is ProductInventoryLoading &&
                state.productStock.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProductInventoryHeader(
                  state: state,
                  onRefresh: cubit.load,
                  onPdf: () => _exportProductPdf(context, state, l10n),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.r,
                      vertical: 0,
                    ),
                    children: [
                      SizedBox(height: 8.h),
                      if (state.stockWasTruncated)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            l10n.inventoryTruncatedWarning(
                              state.stockTotalCount,
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: PernitColors.warning),
                          ),
                        ),
                      _AddProductForm(
                        state: state,
                        isSubmitting: isSubmitting,
                        productId: _productId,
                        warehouseId: _warehouseId,
                        quantityController: _quantityController,
                        error: _error,
                        onProductChanged: (v) => setState(() {
                          _productId = v;
                          _error = null;
                        }),
                        onWarehouseChanged: (v) => setState(() {
                          _warehouseId = v;
                          _error = null;
                        }),
                        onSubmit: () => _submitProduct(cubit, l10n),
                      ),
                      SizedBox(height: 12.h),
                      if (state.productStock.isEmpty)
                        _ProductEmptyState(
                          message: l10n.rawInventoryProductEmpty,
                        )
                      else
                        ..._buildProductList(state),
                    ],
                  ),
                ),
                _ProductBottomBar(
                  onSelected: (index) {
                    if (index < 2) {
                      Navigator.of(context).pop(ProductReturnArgs(index));
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildProductList(ProductInventoryState state) {
    final items = <Widget>[];
    for (final item in state.productStock) {
      items.add(_ProductStockCard(item: item));
      items.add(SizedBox(height: 7.h));
    }
    return items;
  }

  Future<void> _exportProductPdf(
    BuildContext context,
    ProductInventoryState state,
    AppLocalizations l10n,
  ) async {
    final rows = state.productStock
        .map(
          (item) => PdfInventoryRow(
            name: item.productName,
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
          title: l10n.rawInventoryFinishedProductTab,
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
        itemCount: rows.length,
        rows: rows,
        fontData: fontData,
        isRtl: true,
      );
      if (context.mounted) {
        await InventoryPdfExporter.sharePdf(
          bytes,
          filename: 'product_inventory.pdf',
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

  Future<void> _submitProduct(
    ProductInventoryCubit cubit,
    AppLocalizations l10n,
  ) async {
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
    final succeeded = await cubit.addFinishedProductStock(
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

class _AddProductForm extends StatelessWidget {
  final ProductInventoryState state;
  final bool isSubmitting;
  final int? productId;
  final int? warehouseId;
  final TextEditingController quantityController;
  final String? error;
  final ValueChanged<int?> onProductChanged;
  final ValueChanged<int?> onWarehouseChanged;
  final VoidCallback onSubmit;

  const _AddProductForm({
    required this.state,
    required this.isSubmitting,
    required this.productId,
    required this.warehouseId,
    required this.quantityController,
    required this.error,
    required this.onProductChanged,
    required this.onWarehouseChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
            initialValue: productId,
            items: [
              for (final product in state.products)
                DropdownMenuItem(
                  value: product.id,
                  child: Text(product.label, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isSubmitting ? null : onProductChanged,
            decoration: InputDecoration(
              labelText: l10n.rawInventoryProduct,
              prefixIcon: const Icon(Icons.category_outlined),
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<int>(
            initialValue: warehouseId,
            items: [
              for (final warehouse in state.warehouses)
                DropdownMenuItem(
                  value: warehouse.id,
                  child: Text(warehouse.label, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: isSubmitting ? null : onWarehouseChanged,
            decoration: InputDecoration(
              labelText: l10n.rawWorkflowWarehouse,
              prefixIcon: const Icon(Icons.warehouse_outlined),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: quantityController,
            enabled: !isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
            ],
            decoration: InputDecoration(
              labelText: l10n.rawInventoryProductQuantity,
              prefixIcon: const Icon(Icons.numbers_outlined),
            ),
          ),
          if (error != null) ...[
            SizedBox(height: 6.h),
            Text(
              error!,
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
            onPressed: isSubmitting ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ProductStockCard extends StatelessWidget {
  final ProductStockItem item;

  const _ProductStockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 4.h),
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

class _ProductEmptyState extends StatelessWidget {
  final String message;

  const _ProductEmptyState({required this.message});

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

class _ProductInventoryHeader extends StatelessWidget {
  final ProductInventoryState state;
  final VoidCallback onRefresh;
  final VoidCallback onPdf;

  const _ProductInventoryHeader({
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

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.rawInventoryProductCount(count),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
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
            onPressed: state is ProductInventoryLoading ? null : onPdf,
          ),
          IconButton.filledTonal(
            tooltip: l10n.rawWorkflowRefresh,
            onPressed: state is ProductInventoryLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProductBottomBar extends StatelessWidget {
  final ValueChanged<int> onSelected;

  const _ProductBottomBar({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PernitBottomSegmentedBar(
      selectedIndex: 2,
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
