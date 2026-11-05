import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/cart_controller.dart';
import '../../../products/data/product_catalog.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../wishlist_controller.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _showClearWishlistDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(isArabic ? 'إفراغ المفضلة' : 'Clear Wishlist'),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من رغبتك في حذف جميع المنتجات من المفضلة؟'
                : 'Are you sure you want to remove all items from your wishlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                WishlistController.instance.clearWishlist();
                Navigator.pop(dialogContext);
              },
              child: Text(
                isArabic ? 'إفراغ' : 'Clear',
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatPrice(double price, bool isArabic) {
    return isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = LanguageController.instance.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'قائمة المفضلة' : 'My Wishlist',
          style: AppTextStyles.headingSmall.copyWith(
            color: colors.onSurface,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: WishlistController.instance,
            builder: (context, _) {
              if (WishlistController.instance.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: isArabic ? 'إفراغ المفضلة' : 'Clear Wishlist',
                onPressed: () => _showClearWishlistDialog(context, isArabic),
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: WishlistController.instance,
        builder: (context, child) {
          final items = WishlistController.instance.items;

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 72,
                      color: colors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      isArabic
                          ? 'قائمة المفضلة فارغة'
                          : 'Your Wishlist is Empty',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isArabic
                          ? 'احفظ المنتجات التي تعجبك لتجدها وتتسوقها بسهولة هنا.'
                          : 'Save products you like to find and purchase them easily.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final product = items[index];

              return InkWell(
                onTap: () {
                  final catalogProduct = (product.productId != null
                          ? ProductCatalog.getById(product.productId!)
                          : null) ??
                      ProductCatalog.getByName(product.name);

                  if (catalogProduct != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: catalogProduct),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 75,
                        height: 85,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                        ),
                        child: Icon(
                          product.icon,
                          size: 35,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.getDisplayName(isArabic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              product.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _formatPrice(product.price, isArabic),
                              style: AppTextStyles.price.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            tooltip: isArabic ? 'إزالة من المفضلة' : 'Remove',
                            onPressed: () {
                              WishlistController.instance.removeProduct(
                                product.productId ?? product.name,
                              );
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: colors.error,
                            ),
                          ),
                          IconButton(
                            tooltip: isArabic ? 'أضف إلى السلة' : 'Add to Cart',
                            onPressed: () {
                              CartController.instance.addProduct(
                                productId: product.productId,
                                name: product.name,
                                nameAr: product.nameAr,
                                price: product.price,
                                icon: product.icon,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'تمت إضافة (${product.getDisplayName(true)}) إلى السلة'
                                        : '${product.name} added to cart',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
