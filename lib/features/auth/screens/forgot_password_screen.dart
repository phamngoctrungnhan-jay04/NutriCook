import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().sendPasswordResetEmail(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: authProvider.resetEmailSent
              ? _SuccessMessage(email: _emailController.text.trim())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email không được để trống.';
                          }
                          return null;
                        },
                      ),
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          authProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'Gửi link đặt lại mật khẩu',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Trạng thái xác nhận sau khi gửi email thành công — tách riêng khỏi
/// EmptyStateView vì tông màu/ý nghĩa là "thành công", không phải "rỗng".
class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 48,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Đã gửi email đặt lại mật khẩu tới $email. Vui lòng kiểm tra hộp thư '
          '(kể cả mục Spam) và làm theo hướng dẫn trong email.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
