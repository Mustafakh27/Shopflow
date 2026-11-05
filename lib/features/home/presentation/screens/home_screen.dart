import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../../../cart/cart_controller.dart';
import '../../../wishlist/wishlist_controller.dart';
import '../../../products/data/product_catalog.dart';
import '../../../products/presentation/screens/products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = LanguageController.instance.isArabic;

    final featuredProducts = ProductCatalog.getFeatured();
    final newArrivals = ProductCatalog.getNewArrivals();
    final bestSellers = ProductCatalog.getBestSellers();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ShopFlow',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: CartController.instance,
                    builder: (context, _) {
                      final count = CartController.instance.itemCount;
                      return IconButton(
                        tooltip: isArabic ? 'السلة' : 'Cart',
                        onPressed: () {
                          MainNavigationScreen.switchToTab(context, 3);
                        },
                        icon: count > 0
                            ? Badge.count(
                                count: count,
                                child: const Icon(Icons.shopping_bag_outlined),
                              )
                            : const Icon(Icons.shopping_bag_outlined),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Welcome Section
              Text(
                isArabic ? 'اكتشف أسلوبك' : 'Discover Your Style',
                style: AppTextStyles.headingLarge.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                isArabic
                    ? 'أحدث صيحات الأزياء والإكسسوارات الفاخرة.'
                    : 'The latest curated fashion trends & accessories.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Search Bar Entry Point
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isArabic ? 'ابحث عن المنتجات...' : 'Search products...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(Icons.tune_outlined, size: 20, color: colors.secondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Promotional Hero Banner
              _buildPromoBanner(context, colors, isArabic),

              const SizedBox(height: AppSpacing.xxl),

              // Categories Header
              _buildSectionHeader(
                title: isArabic ? 'التصنيفات' : 'Categories',
                actionText: isArabic ? 'عرض الكل' : 'See all',
                colors: colors,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(initialCategory: 'All'),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Categories Horizontal List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(
                      context,
                      isArabic ? 'رجالي' : 'Men',
                      'Men',
                      Icons.male,
                      colors,
                    ),
                    _buildCategoryChip(
                      context,
                      isArabic ? 'حريمي' : 'Women',
                      'Women',
                      Icons.female,
                      colors,
                    ),
                    _buildCategoryChip(
                      context,
                      isArabic ? 'أحذية' : 'Shoes',
                      'Shoes',
                      Icons.directions_walk,
                      colors,
                    ),
                    _buildCategoryChip(
                      context,
                      isArabic ? 'إكسسوارات' : 'Accessories',
                      'Accessories',
                      Icons.watch,
                      colors,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Featured Products Header
              _buildSectionHeader(
                title: isArabic ? 'منتجات مميزة' : 'Featured Products',
                actionText: isArabic ? 'عرض الكل' : 'See all',
                colors: colors,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Featured Products Horizontal List
              _buildProductHorizontalList(context, featuredProducts, colors, isArabic),

              const SizedBox(height: AppSpacing.xxl),

              // New Arrivals Section
              _buildSectionHeader(
                title: isArabic ? 'وصل حديثاً' : 'New Arrivals',
                actionText: isArabic ? 'عرض الكل' : 'See all',
                colors: colors,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // New Arrivals Horizontal List
              _buildProductHorizontalList(context, newArrivals, colors, isArabic),

              const SizedBox(height: AppSpacing.xxl),

              // Best Sellers Section
              _buildSectionHeader(
                title: isArabic ? 'الأكثر مبيعاً' : 'Best Sellers',
                actionText: isArabic ? 'عرض الكل' : 'See all',
                colors: colors,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Best Sellers Horizontal List
              _buildProductHorizontalList(context, bestSellers, colors, isArabic),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context, ColorScheme colors, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.85),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isArabic ? 'عرض خاص' : 'LIMITED OFFER',
              style: TextStyle(
                color: colors.onSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isArabic ? 'تشكيلة الموسم الجديد\nخصم حتى 30%' : 'New Season Collection\nUp to 30% Off',
            style: AppTextStyles.headingSmall.copyWith(
              color: colors.onPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.surface,
              foregroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductsScreen(),
                ),
              );
            },
            child: Text(isArabic ? 'تسوق الآن' : 'Shop Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required ColorScheme colors,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            color: colors.onSurface,
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              actionText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String categoryKey,
    IconData icon,
    ColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductsScreen(initialCategory: categoryKey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHorizontalList(
    BuildContext context,
    List<Product> products,
    ColorScheme colors,
    bool isArabic,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: products.map((product) {
          final priceFormatted = isArabic
              ? '${product.price.toStringAsFixed(0)} جنيه'
              : '${product.price.toStringAsFixed(0)} EGP';

          return Container(
            width: 155,
            margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        width: 155,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Center(
                          child: Icon(
                            product.icon,
                            size: 50,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 4,
                        end: 4,
                        child: AnimatedBuilder(
                          animation: WishlistController.instance,
                          builder: (context, _) {
                            final isFav = WishlistController.instance.isFavorite(product.id);
                            return IconButton(
                              iconSize: 18,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                WishlistController.instance.toggleFromProduct(product);
                              },
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? colors.error : colors.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    product.getName(isArabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    priceFormatted,
                    style: AppTextStyles.price.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
