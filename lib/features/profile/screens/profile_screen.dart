import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/profile_provider.dart';
import 'widgets/avatar_picker_sheet.dart';
import 'widgets/avatar_widget.dart';
import 'widgets/bmi_card.dart';
import 'widgets/edit_profile_form.dart';
import 'widgets/profile_settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().loadProfile();
  }

  Future<void> _handleEditAvatar(BuildContext context) async {
    final file = await AvatarPickerSheet.show(context);
    if (file == null || !context.mounted) return;

    final success = await context.read<ProfileProvider>().uploadAvatar(file);
    if (!context.mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể tải ảnh lên, vui lòng thử lại.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ProfileProvider provider) {
    switch (provider.status) {
      case ProfileStatus.idle:
      case ProfileStatus.loading:
        return const LoadingIndicator();
      case ProfileStatus.error:
        return ErrorView(
          message: provider.errorMessage ?? 'Đã xảy ra lỗi, vui lòng thử lại.',
          onRetry: () => context.read<ProfileProvider>().loadProfile(),
        );
      case ProfileStatus.success:
        final profile = provider.profile!;
        final displayName = profile.name.isEmpty ? profile.email : profile.name;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            Center(
              child: AvatarWidget(
                name: displayName,
                avatarUrl: profile.avatarUrl,
                isUploading: provider.isUploadingAvatar,
                onEdit: () => _handleEditAvatar(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(displayName, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: BmiCard(bmi: provider.bmi),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: EditProfileForm(profile: profile),
            ),
            const SizedBox(height: AppSpacing.xl),
            const ProfileSettingsSection(),
          ],
        );
    }
  }
}
