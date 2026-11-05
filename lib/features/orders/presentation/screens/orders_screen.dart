import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../order_controller.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: OrderController.instance,
      builder: (context, child) {
        final orders = OrderController.instance.orders;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isArabic ? 'طلباتي' : 'My Orders',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          body: orders.isEmpty
              ? _buildEmptyState(colors)
              : ListView.separated(
                  padding: const EdgeInsets.all(
                    AppSpacing.screenPadding,
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return _OrderCard(order: order);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 75,
            color: colors.secondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _isArabic ? 'لا توجد طلبات حتى الآن' : 'No orders yet',
            style: AppTextStyles.headingMedium.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isArabic
                ? 'ستظهر جميع طلباتك السابقة والحالية هنا.'
                : 'Your past and active orders will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;

  const _OrderCard({required this.order});

  bool get _isArabic => LanguageController.instance.isArabic;

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Shipped':
        return Colors.blue;
      case 'Processing':
      case 'Confirmed':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusName(String status) {
    if (!_isArabic) return status;

    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'Confirmed':
        return 'تم التأكيد';
      case 'Processing':
        return 'جاري التجهيز';
      case 'Shipped':
        return 'تم الشحن';
      case 'Delivered':
        return 'تم التوصيل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isArabic
                        ? 'طلب رقم #${order.id}'
                        : 'Order #${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusName(order.status),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _statusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isArabic
                  ? '${order.items.length} منتجات في الطلب'
                  : '${order.items.length} items in order',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatPrice(order.total),
                  style: AppTextStyles.price.copyWith(
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                _isArabic ? 'عرض التفاصيل ←' : 'View Details →',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return _isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  bool get _isArabic => LanguageController.instance.isArabic;

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Shipped':
        return Colors.blue;
      case 'Processing':
      case 'Confirmed':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusName(String status) {
    if (!_isArabic) return status;

    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'Confirmed':
        return 'تم التأكيد';
      case 'Processing':
        return 'جاري التجهيز';
      case 'Shipped':
        return 'تم الشحن';
      case 'Delivered':
        return 'تم التوصيل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatPrice(double price) {
    return _isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }

  void _confirmCancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(_isArabic ? 'إلغاء الطلب' : 'Cancel Order'),
          content: Text(
            _isArabic
                ? 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'
                : 'Are you sure you want to cancel this order?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_isArabic ? 'لا' : 'No'),
            ),
            TextButton(
              onPressed: () {
                OrderController.instance.cancelOrder(order);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isArabic ? 'تم إلغاء الطلب بنجاح' : 'Order cancelled successfully',
                    ),
                  ),
                );
              },
              child: Text(
                _isArabic ? 'نعم، إلغاء' : 'Yes, Cancel',
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

    return AnimatedBuilder(
      animation: OrderController.instance,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isArabic ? 'تفاصيل الطلب' : 'Order Details',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic
                      ? 'طلب رقم #${order.id}'
                      : 'Order #${order.id}',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: _statusColor(order.status),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _getStatusName(order.status),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _statusColor(order.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (order.canBeCancelled)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            side: BorderSide(color: colors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          onPressed: () => _confirmCancelOrder(context),
                          child: Text(_isArabic ? 'إلغاء الطلب' : 'Cancel'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  _isArabic ? 'المنتجات المطلوبة' : 'Ordered Products',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: colors.secondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.getDisplayName(_isArabic),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _isArabic
                                        ? 'الكمية: ${item.quantity}'
                                        : 'Qty: ${item.quantity}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  if (item.selectedSize != null) ...[
                                    Text(' • ', style: TextStyle(color: colors.onSurfaceVariant)),
                                    Text(
                                      _isArabic ? 'المقاس: ${item.selectedSize}' : 'Size: ${item.selectedSize}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatPrice(item.total),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: AppSpacing.xl),

                Text(
                  _isArabic ? 'معلومات التوصيل' : 'Delivery Information',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: _isArabic ? 'الاسم' : 'Name',
                  value: order.customerName,
                ),
                _InfoRow(
                  label: _isArabic ? 'الهاتف' : 'Phone',
                  value: order.phone,
                ),
                _InfoRow(
                  label: _isArabic ? 'المدينة' : 'City',
                  value: order.city,
                ),
                _InfoRow(
                  label: _isArabic ? 'العنوان' : 'Address',
                  value: order.address,
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  _isArabic ? 'طريقة الدفع' : 'Payment Method',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _isArabic && order.paymentMethod == 'Cash on Delivery'
                      ? 'الدفع عند الاستلام'
                      : order.paymentMethod,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const Divider(height: AppSpacing.xl),

                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isArabic ? 'المجموع الفرعي' : 'Subtotal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatPrice(order.subtotal),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Delivery Fee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isArabic ? 'رسوم التوصيل' : 'Delivery Fee',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      order.deliveryFee == 0.0
                          ? (_isArabic ? 'مجاني' : 'FREE')
                          : _formatPrice(order.deliveryFee),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: order.deliveryFee == 0.0 ? Colors.green : colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Divider(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isArabic ? 'إجمالي الطلب' : 'Order Total',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      _formatPrice(order.total),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  _isArabic
                      ? 'تاريخ الطلب: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}  ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}'
                      : 'Order Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}  ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
