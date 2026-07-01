import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/pernit_colors.dart';

class PernitLookupItem<T> {
  final T value;
  final String label;
  final String? subtitle;

  const PernitLookupItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

class PernitLookupAutocompleteField<T> extends StatefulWidget {
  final Future<List<PernitLookupItem<T>>> Function(String query) fetchItems;
  final PernitLookupItem<T>? selectedItem;
  final ValueChanged<PernitLookupItem<T>> onSelected;
  final String labelText;
  final String hintText;
  final String emptyText;
  final String errorText;
  final String loadingText;
  final VoidCallback? onRefresh;

  const PernitLookupAutocompleteField({
    super.key,
    required this.fetchItems,
    this.selectedItem,
    required this.onSelected,
    required this.labelText,
    required this.hintText,
    required this.emptyText,
    required this.errorText,
    required this.loadingText,
    this.onRefresh,
  });

  @override
  State<PernitLookupAutocompleteField<T>> createState() =>
      _PernitLookupAutocompleteFieldState<T>();
}

class _PernitLookupAutocompleteFieldState<T>
    extends State<PernitLookupAutocompleteField<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<PernitLookupItem<T>> _items = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.selectedItem != null) {
      _controller.text = widget.selectedItem!.label;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  Future<void> _search(String query) async {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _items = [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.fetchItems(query.trim());
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _error = widget.errorText;
        _isLoading = false;
      });
    }
  }

  void _selectItem(PernitLookupItem<T> item) {
    _controller.text = item.label;
    _items = [];
    _focusNode.unfocus();
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: _isLoading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: Center(
                      child: SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.r,
                          color: PernitColors.primary,
                        ),
                      ),
                    ),
                  )
                : (_controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 18.r),
                          onPressed: () {
                            _controller.clear();
                            _items = [];
                            setState(() {});
                          },
                        )
                      : null),
          ),
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), () {
              _search(value);
            });
            if (value.isEmpty) {
              setState(() => _items = []);
            }
          },
        ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _error!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: PernitColors.danger),
                  ),
                ),
                if (widget.onRefresh != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _error = null);
                      widget.onRefresh?.call();
                    },
                    icon: Icon(Icons.refresh, size: 14.r),
                    label: Text('Retry', style: TextStyle(fontSize: 12.sp)),
                  ),
              ],
            ),
          ),
        if (_items.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200.h),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 4.h),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return InkWell(
                  onTap: () => _selectItem(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: PernitColors.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: PernitColors.borderMuted,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (item.subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: PernitColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (_items.isEmpty &&
            !_isLoading &&
            _error == null &&
            _controller.text.trim().isNotEmpty &&
            !_focusNode.hasPrimaryFocus)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              widget.emptyText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
            ),
          ),
      ],
    );
  }
}
