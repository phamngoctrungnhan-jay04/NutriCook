import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/meal_provider.dart';

/// Thanh tìm kiếm — tự quản lý TextEditingController cục bộ, gọi
/// [MealProvider.onSearchChanged] (có Debounce bên trong Provider) mỗi khi gõ.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    context.read<MealProvider>().onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: (value) => context.read<MealProvider>().onSearchChanged(value),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm món ăn...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: _handleClear),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: AppRadius.chipRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
