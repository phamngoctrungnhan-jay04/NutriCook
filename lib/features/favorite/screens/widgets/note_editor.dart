import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../dtos/update_favorite_note_request_dto.dart';
import '../../models/favorite_meal_model.dart';
import '../../providers/favorite_provider.dart';

/// Bottom Sheet sửa ghi chú cá nhân cho 1 món yêu thích (Update, FR-FAV-04).
class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.favorite});

  final FavoriteMealModel favorite;

  static Future<void> show(BuildContext context, FavoriteMealModel favorite) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.dialog)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: NoteEditor(favorite: favorite),
      ),
    );
  }

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.favorite.note);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final success = await context.read<FavoriteProvider>().updateNote(
          widget.favorite.idMeal,
          _controller.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu ghi chú, vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.favorite.mealName, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: UpdateFavoriteNoteRequestDto.maxLength,
            decoration: const InputDecoration(
              labelText: 'Ghi chú cá nhân',
              hintText: 'Ví dụ: cần giảm nửa lượng đường...',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Lưu', isLoading: _isSaving, onPressed: _handleSave),
        ],
      ),
    );
  }
}
