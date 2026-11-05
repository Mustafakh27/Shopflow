import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth_controller.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final identifier = _identifierController.text.trim();
    final name = identifier.contains('@') ? identifier.split('@').first : 'Customer';

    await AuthController.instance.setSessionUser(
      UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: identifier.contains('@') ? identifier : '$identifier@shopflow.eg',
        phone: RegExp(r'^01[0-9]{9}$').hasMatch(identifier) ? identifier : '01000000000',
        createdAt: DateTime.now(),
      ),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic
                ? 'مرحبًا بك مجددًا في ShopFlow!'
                : 'Welcome back to ShopFlow!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isArabic ? 'تسجيل الدخول' : 'Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isArabic ? 'مرحبًا بك مجددًا' : 'Welcome Back',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _isArabic
                      ? 'سجل دخولك لمتابعة طلباتك ومزامنة مشترياتك.'
                      : 'Sign in to track orders and sync your preferences.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Notice alert about Firebase readiness
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(color: colors.secondary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: colors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _isArabic
                              ? 'جاهز لربط Firebase Auth. يمكنك تجربة تسجيل الدخول أو التصفح كزائر.'
                              : 'Ready for Firebase Auth. You can sign in locally or continue as a guest.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Email / Phone Field
                Text(
                  _isArabic ? 'البريد الإلكتروني أو رقم الهاتف' : 'Email or Phone Number',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: _isArabic ? 'name@example.com أو 01XXXXXXXXX' : 'name@example.com or 01XXXXXXXXX',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isArabic
                          ? 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف'
                          : 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Password Field
                Text(
                  _isArabic ? 'كلمة المرور' : 'Password',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return _isArabic
                          ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف'
                          : 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                // Forgot Password link
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      _isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isArabic ? 'تسجيل الدخول' : 'Sign In', style: AppTextStyles.button),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Continue as Guest Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      AuthController.instance.signOut();
                      Navigator.pop(context);
                    },
                    child: Text(
                      _isArabic ? 'المتابعة كزائر' : 'Continue as Guest',
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isArabic ? 'ليس لديك حساب؟' : "Don't have an account?",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        _isArabic ? 'إنشاء حساب جديد' : 'Register Now',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
