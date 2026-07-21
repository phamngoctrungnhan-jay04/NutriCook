import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/providers/auth_provider.dart';

/// Mục Cài đặt — hiện chỉ có Đăng xuất (FR-PROFILE-06). Các mục cài đặt phổ
/// biến khác (đổi theme thủ công, ngôn ngữ, thông báo) đã bị loại khỏi phạm vi
/// MVP ở UI_UX_GUIDELINES.md/PROJECT_REQUIREMENTS.md.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi NutriCook?',
      confirmLabel: 'Đăng xuất',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Cài đặt', style: theme.textTheme.titleLarge),
        ),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: const Text('Đăng xuất'),
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
}
