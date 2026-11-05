
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/main_navigation_screen.dart';
import 'core/language/language_controller.dart';

import 'features/cart/cart_controller.dart';
import 'features/wishlist/wishlist_controller.dart';
import 'features/orders/order_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeController.instance.loadThemeMode();
  await LanguageController.instance.loadLanguage();
  await CartController.instance.loadCart();
  await WishlistController.instance.loadWishlist();
  await OrderController.instance.loadOrders();

  runApp(const ShopFlowApp());
}

class ShopFlowApp extends StatelessWidget {
  const ShopFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LanguageController.instance,
      ]),
      builder: (context, child) {
        return MaterialApp(
          title: 'ShopFlow',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,

          locale: LanguageController.instance.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
