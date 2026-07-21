import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../models/user_profile_model.dart';
import '../../providers/profile_provider.dart';

/// Form chỉnh sửa hồ sơ — tên, chiều cao, cân nặng hiện tại, cân nặng mục tiêu.
class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _currentWeightController;
  late final TextEditingController _targetWeightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _heightController = TextEditingController(text: widget.profile.height?.toString() ?? '');
    _currentWeightController =
        TextEditingController(text: widget.profile.currentWeight?.toString() ?? '');
    _targetWeightController =
        TextEditingController(text: widget.profile.targetWeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<ProfileProvider>().updateProfile(
          name: _nameController.text.trim(),
          height: double.tryParse(_heightController.text.trim()),
          currentWeight: double.tryParse(_currentWeightController.text.trim()),
          targetWeight: double.tryParse(_targetWeightController.text.trim()),
        );

    if (!mounted) return;
    final message = success ? 'Đã cập nhật hồ sơ.' : 'Không thể lưu, vui lòng thử lại.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Phải là số dương.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Tên hiển thị',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Tên không được để trống.';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Chiều cao (cm)',
            controller: _heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Cân nặng hiện tại (kg)',
            controller: _currentWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Cân nặng mục tiêu (kg)',
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validatePositiveNumber,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Lưu thay đổi',
            isLoading: provider.isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
