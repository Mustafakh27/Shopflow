import 'package:flutter/material.dart';

import '../../cart_controller.dart';
import 'checkout_screen.dart';
import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showClearCartDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(isArabic ? 'إفراغ السلة' : 'Clear Cart'),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من رغبتك في حذف جميع المنتجات من السلة؟'
                : 'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                CartController.instance.clearCart();
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

    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, child) {
        final cart = CartController.instance;
        final items = cart.items;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isArabic ? 'سلة التسوق' : 'My Cart',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  tooltip: isArabic ? 'إفراغ السلة' : 'Clear Cart',
                  onPressed: () => _showClearCartDialog(context, isArabic),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: items.isEmpty
              ? _buildEmptyCart(colors, isArabic)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return _CartProductCard(
                            item: item,
                            isArabic: isArabic,
                            onIncrease: () {
                              final increased = cart.increaseQuantity(item);
                              if (!increased) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isArabic
                                          ? 'تم الوصول إلى أقصى كمية متاحة في المخزون (${item.maxStock})'
                                          : 'Reached maximum available stock (${item.maxStock})',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            onDecrease: () {
                              cart.decreaseQuantity(item);
                            },
                            onRemove: () {
                              cart.removeProduct(item);
                            },
                          );
                        },
                      ),
                    ),
                    _buildSummary(context, cart, isArabic),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart(ColorScheme colors, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 75,
            color: colors.secondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isArabic ? 'سلة التسوق فارغة' : 'Your cart is empty',
            style: AppTextStyles.headingMedium.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isArabic
                ? 'أضف بعض المنتجات للبدء.'
                : 'Add some products to get started.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    CartController cart,
    bool isArabic,
  ) {
    final colors = Theme.of(context).colorScheme;
    final remainingForFree = CartController.freeDeliveryThreshold - cart.subtotal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        children: [
          // Free Shipping Progress Note
          if (remainingForFree > 0)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, size: 18, color: colors.secondary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'أضف ${_formatPrice(remainingForFree, isArabic)} إضافية للحصول على شحن مجاني!'
                          : 'Add ${_formatPrice(remainingForFree, isArabic)} more for FREE delivery!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic
                    ? 'المنتجات (${cart.itemCount})'
                    : 'Items (${cart.itemCount})',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatPrice(cart.subtotal, isArabic),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Delivery Fee Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'رسوم التوصيل' : 'Delivery Fee',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                cart.isFreeDelivery
                    ? (isArabic ? 'مجاني' : 'FREE')
                    : _formatPrice(cart.deliveryFee, isArabic),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: cart.isFreeDelivery ? Colors.green : colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg),

          // Grand Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'الإجمالي' : 'Total',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              Text(
                _formatPrice(cart.grandTotal, isArabic),
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Proceed to Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
              child: Text(
                isArabic ? 'إتمام الشراء' : 'Proceed to Checkout',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartProductCard extends StatelessWidget {
  final CartItem item;
  final bool isArabic;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartProductCard({
    required this.item,
    required this.isArabic,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 95,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            child: Icon(
              item.icon,
              size: 38,
              color: colors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getDisplayName(isArabic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.selectedSize != null || item.selectedColor != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.selectedSize != null)
                        Text(
                          isArabic ? 'المقاس: ${item.selectedSize}' : 'Size: ${item.selectedSize}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      if (item.selectedSize != null && item.selectedColor != null)
                        Text(' • ', style: TextStyle(color: colors.onSurfaceVariant)),
                      if (item.selectedColor != null)
                        Row(
                          children: [
                            Text(
                              isArabic ? 'اللون: ' : 'Color: ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(item.selectedColor!),
                                border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isArabic
                      ? '${item.price.toStringAsFixed(0)} جنيه'
                      : '${item.price.toStringAsFixed(0)} EGP',
                  style: AppTextStyles.price.copyWith(
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: onDecrease,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isArabic ? 'حذف المنتج' : 'Remove product',
            onPressed: onRemove,
            icon: Icon(
              Icons.delete_outline,
              color: colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
