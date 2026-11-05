import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/language/language_controller.dart';
import '../../../auth/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showHelpSupportDialog(BuildContext context, bool isArabic) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isArabic ? 'المساعدة والدعم' : 'Help & Support',
                  style: AppTextStyles.headingSmall.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.headset_mic_outlined, color: colors.primary),
                  title: Text(isArabic ? 'خدمة العملاء (مصر)' : 'Customer Service (Egypt)'),
                  subtitle: const Text('19888 (9:00 AM - 10:00 PM)'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.email_outlined, color: colors.primary),
                  title: Text(isArabic ? 'البريد الإلكتروني' : 'Email Support'),
                  subtitle: const Text('support@shopflow.eg'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.local_shipping_outlined, color: colors.primary),
                  title: Text(isArabic ? 'سياسة التوصيل والإرجاع' : 'Shipping & Return Policy'),
                  subtitle: Text(
                    isArabic
                        ? 'توصيل خلال 2-4 أيام عمل في جميع محافظات مصر، وإرجاع مجاني خلال 14 يومًا.'
                        : 'Delivery in 2-4 business days across Egypt. Free returns within 14 days.',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutShopFlowDialog(BuildContext context, bool isArabic) {
    showAboutDialog(
      context: context,
      applicationName: 'ShopFlow',
      applicationVersion: '1.0.0',
      applicationLegalese: isArabic
          ? 'تطبيق تجارة إلكترونية عصري للأزياء والإكسسوارات في مصر.\nالعملة: الجنيه المصري (EGP).\nبنية تطبيق مهيأة لربط Firebase.'
          : 'A modern fashion and accessories e-commerce application tailored for Egypt.\nCurrency: Egyptian Pound (EGP).\nArchitecture ready for Firebase backend integration.',
    );
  }

  void _confirmSignOut(BuildContext context, bool isArabic) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isArabic ? 'تسجيل الخروج' : 'Sign Out'),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من رغبتك في تسجيل الخروج؟ ستتمكن من متابعة التسوق كزائر.'
                : 'Are you sure you want to sign out? You can continue shopping as a guest.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                AuthController.instance.signOut();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic ? 'تم تسجيل الخروج بنجاح' : 'Signed out successfully',
                    ),
                  ),
                );
              },
              child: Text(
                isArabic ? 'خروج' : 'Sign Out',
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = LanguageController.instance.isArabic;

    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        final user = auth.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isArabic ? 'ملفي الشخصي' : 'My Profile',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                tooltip: isArabic ? 'الإعدادات' : 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildProfileHeader(colors, isArabic, user),

              // If guest, show a call-to-action banner to Sign In / Register
              if (auth.isGuest) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle_outlined, size: 40, color: colors.secondary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'تسوق بأمان وسهولة' : 'Shop with Confidence',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isArabic ? 'سجل دخولك أو أنشئ حسابك الآن' : 'Sign in or create an account',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(isArabic ? 'دخول' : 'Sign In'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              Text(
                isArabic ? 'حسابي' : 'My Account',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: isArabic ? 'طلباتي' : 'My Orders',
                subtitle: isArabic ? 'عرض سجل طلباتك وحالاتها' : 'View order history & live status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrdersScreen(),
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_border,
                title: isArabic ? 'المفضلة' : 'My Wishlist',
                subtitle: isArabic ? 'المنتجات المحفوظة للتسوق لاحقًا' : 'Your saved products',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WishlistScreen(),
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.location_on_outlined,
                title: isArabic ? 'عناويني' : 'My Addresses',
                subtitle: isArabic ? 'إدارة عناوين التوصيل في مصر' : 'Manage your delivery addresses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddressesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                isArabic ? 'التفضيلات والدعم' : 'Preferences & Support',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: isArabic ? 'الإعدادات' : 'Settings',
                subtitle: isArabic ? 'المظهر واللغة والعملة' : 'Theme, language, and currency',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.headset_mic_outlined,
                title: isArabic ? 'المساعدة والدعم' : 'Help & Support',
                subtitle: isArabic ? 'الخط الساخن والأسئلة الشائعة' : 'Hotline, returns, and FAQs',
                onTap: () => _showHelpSupportDialog(context, isArabic),
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline,
                title: isArabic ? 'عن ShopFlow' : 'About ShopFlow',
                subtitle: isArabic ? 'معلومات التطبيق والإصدار' : 'App details & version info',
                onTap: () => _showAboutShopFlowDialog(context, isArabic),
              ),

              const SizedBox(height: AppSpacing.xl),

              if (auth.isAuthenticated)
                OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, isArabic),
                  icon: const Icon(Icons.logout),
                  label: Text(isArabic ? 'تسجيل الخروج' : 'Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ColorScheme colors, bool isArabic, UserModel? user) {
    final isGuest = user == null;

    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: colors.surfaceContainerHighest,
          child: Icon(
            isGuest ? Icons.person_outline : Icons.check_circle_outline,
            size: 48,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          isGuest
              ? (isArabic ? 'زائر متسوق' : 'Guest Shopper')
              : user.name,
          style: AppTextStyles.headingMedium.copyWith(
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isGuest
              ? (isArabic ? 'تسوق كزائر أو سجل الدخول' : 'Browsing as guest')
              : '${user.email} • ${user.phone}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = LanguageController.instance.isArabic;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      leading: Icon(icon, color: colors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        isArabic ? Icons.chevron_left : Icons.chevron_right,
        color: colors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: LanguageController.instance,
      builder: (context, child) {
        final isArabic = LanguageController.instance.isArabic;

        return Scaffold(
          appBar: AppBar(
            title: Text(isArabic ? 'الإعدادات' : 'Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text(
                isArabic ? 'المظهر' : 'Appearance',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, child) {
                  final selectedMode = ThemeController.instance.themeMode;

                  return RadioGroup<ThemeMode>(
                    groupValue: selectedMode,
                    onChanged: (mode) {
                      if (mode != null) ThemeController.instance.setThemeMode(mode);
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          value: ThemeMode.system,
                          title: Text(isArabic ? 'إعدادات الجهاز' : 'System Default'),
                          subtitle: Text(isArabic ? 'استخدام سمة الجهاز' : 'Follow device settings'),
                          secondary: const Icon(Icons.settings_suggest_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          value: ThemeMode.light,
                          title: Text(isArabic ? 'الوضع الفاتح' : 'Light Mode'),
                          secondary: const Icon(Icons.light_mode_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          contentPadding: EdgeInsets.zero,
                          value: ThemeMode.dark,
                          title: Text(isArabic ? 'الوضع الداكن' : 'Dark Mode'),
                          secondary: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: AppSpacing.xxl),
              Text(
                isArabic ? 'اللغة' : 'Language',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RadioGroup<String>(
                groupValue: LanguageController.instance.locale.languageCode,
                onChanged: (val) {
                  if (val != null) LanguageController.instance.setLanguage(Locale(val));
                },
                child: const Column(
                  children: [
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'en',
                      title: Text('English (LTR)'),
                      secondary: Icon(Icons.language),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: 'ar',
                      title: Text('العربية (RTL)'),
                      secondary: Icon(Icons.translate),
                    ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.xxl),
              Text(
                isArabic ? 'العملة والإشعارات' : 'Currency & Notifications',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.currency_exchange_outlined),
                title: Text(isArabic ? 'العملة' : 'Currency'),
                subtitle: Text(
                  isArabic ? 'الجنيه المصري (EGP)' : 'Egyptian Pound (EGP)',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('EGP / ج.م', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.notifications_outlined,
                  color: colors.primary,
                ),
                title: Text(
                  isArabic ? 'الإشعارات' : 'Notifications',
                ),
                subtitle: Text(
                  isArabic
                      ? 'مجهزة لربط Firebase Cloud Messaging (FCM)'
                      : 'Prepared for Firebase Cloud Messaging (FCM)',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isArabic ? 'المرحلة القادمة' : 'Next Phase',
                    style: TextStyle(
                      color: colors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
