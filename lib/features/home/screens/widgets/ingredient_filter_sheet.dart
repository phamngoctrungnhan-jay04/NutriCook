import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';

/// Bottom sheet chọn nhiều nguyên liệu (checkbox) có hỗ trợ tìm kiếm nguyên liệu
/// và hiển thị danh sách nguyên liệu đã chọn dạng chip.
class IngredientFilterSheet extends StatefulWidget {
  const IngredientFilterSheet({
    super.key,
    required this.ingredients,
    required this.selected,
  });

  final List<String> ingredients;
  final Set<String> selected;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<String> ingredients,
    required Set<String> selected,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.dialog)),
      ),
      builder: (_) => IngredientFilterSheet(ingredients: ingredients, selected: selected),
    );
  }

  @override
  State<IngredientFilterSheet> createState() => _IngredientFilterSheetState();
}

class _IngredientFilterSheetState extends State<IngredientFilterSheet> {
  late final Set<String> _temp = {...widget.selected};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lọc danh sách nguyên liệu theo từ khóa tìm kiếm
    final filteredIngredients = widget.ingredients
        .where((ing) => ing.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by ingredients', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Thanh tìm kiếm nguyên liệu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ingredients...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: AppRadius.textFieldRadius,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Hiển thị các nguyên liệu đã chọn dạng chip ngang
          if (_temp.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _temp.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: InputChip(
                      label: Text(ingredient),
                      onDeleted: () {
                        setState(() {
                          _temp.remove(ingredient);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Danh sách nguyên liệu với checkbox
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
            child: filteredIngredients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(
                        'No matching ingredients found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.labelMedium?.color,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = filteredIngredients[index];
                      final checked = _temp.contains(ingredient);
                      return CheckboxListTile(
                        title: Text(ingredient),
                        value: checked,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) => setState(() {
                          if (value ?? false) {
                            _temp.add(ingredient);
                          } else {
                            _temp.remove(ingredient);
                          }
                        }),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Hàng nút hành động
          Row(
            children: [
              TextButton(
                onPressed: _temp.isEmpty ? null : () => setState(_temp.clear),
                child: const Text('Clear all'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'Apply',
                  onPressed: () => Navigator.of(context).pop(_temp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
