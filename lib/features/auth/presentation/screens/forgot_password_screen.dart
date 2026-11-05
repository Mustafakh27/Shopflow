import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _sent = false;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendReset() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isArabic ? 'استعادة كلمة المرور' : 'Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: _sent
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_read_outlined, size: 72, color: colors.primary),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _isArabic ? 'تم إرسال الرابط' : 'Link Sent!',
                        style: AppTextStyles.headingMedium.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _isArabic
                            ? 'تم إرسال تعليمات إعادة تعيين كلمة المرور إلى ${_controller.text}.'
                            : 'Password reset instructions have been sent to ${_controller.text}.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(_isArabic ? 'العودة لتسجيل الدخول' : 'Back to Login'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                        style: AppTextStyles.headingLarge.copyWith(color: colors.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _isArabic
                            ? 'أدخل بريدك الإلكتروني أو رقم هاتفك وسنرسل لك رابطًا لاستعادة حسابك.'
                            : 'Enter your email or phone number and we will send you a reset link.',
                        style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: _isArabic ? 'name@example.com أو 01XXXXXXXXX' : 'name@example.com or 01XXXXXXXXX',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _isArabic ? 'يرجى إدخال البريد أو الهاتف' : 'Please enter email or phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _sendReset,
                          child: Text(_isArabic ? 'إرسال رابط الاستعادة' : 'Send Reset Link'),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
