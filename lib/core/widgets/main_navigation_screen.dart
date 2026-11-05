import 'package:flutter/material.dart';

import '../language/language_controller.dart';
import '../../features/cart/cart_controller.dart';
import '../../features/wishlist/wishlist_controller.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
    state?.setTab(index);
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void setTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductsScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = LanguageController.instance.isArabic;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: Listenable.merge([
          CartController.instance,
          WishlistController.instance,
        ]),
        builder: (context, _) {
          final cartCount = CartController.instance.itemCount;
          final wishlistCount = WishlistController.instance.items.length;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: setTab,
            backgroundColor: colors.surface,
            indicatorColor: colors.secondary.withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: isArabic ? 'الرئيسية' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.search),
                selectedIcon: const Icon(Icons.manage_search),
                label: isArabic ? 'المنتجات' : 'Products',
              ),
              NavigationDestination(
                icon: wishlistCount > 0
                    ? Badge.count(
                        count: wishlistCount,
                        child: const Icon(Icons.favorite_border),
                      )
                    : const Icon(Icons.favorite_border),
                selectedIcon: wishlistCount > 0
                    ? Badge.count(
                        count: wishlistCount,
                        child: const Icon(Icons.favorite),
                      )
                    : const Icon(Icons.favorite),
                label: isArabic ? 'المفضلة' : 'Wishlist',
              ),
              NavigationDestination(
                icon: cartCount > 0
                    ? Badge.count(
                        count: cartCount,
                        child: const Icon(Icons.shopping_bag_outlined),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                selectedIcon: cartCount > 0
                    ? Badge.count(
                        count: cartCount,
                        child: const Icon(Icons.shopping_bag),
                      )
                    : const Icon(Icons.shopping_bag),
                label: isArabic ? 'السلة' : 'Cart',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: isArabic ? 'حسابي' : 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
