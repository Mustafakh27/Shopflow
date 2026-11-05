import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../profile/presentation/screens/addresses_screen.dart';
import '../../cart_controller.dart';
import '../../../orders/order_controller.dart';
import '../../../orders/presentation/screens/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  static const String _addressesStorageKey = 'shopflow_addresses';

  List<CustomerAddress> _savedAddresses = [];
  String? _selectedAddressId;

  bool _isLoadingAddresses = true;
  bool _isPlacingOrder = false;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_addressesStorageKey);

      if (savedData != null) {
        final decoded = jsonDecode(savedData) as List;

        _savedAddresses = decoded
            .map(
              (item) => CustomerAddress.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }

      if (_savedAddresses.isNotEmpty) {
        final defaultAddress = _savedAddresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => _savedAddresses.first,
        );

        _selectAddress(defaultAddress);
      }
    } catch (_) {
      _savedAddresses = [];
    }

    if (!mounted) return;

    setState(() {
      _isLoadingAddresses = false;
    });
  }

  void _selectAddress(CustomerAddress address) {
    setState(() {
      _selectedAddressId = address.id;

      _nameController.text = address.name;
      _phoneController.text = address.phone;
      _cityController.text = address.city;
      _addressController.text = address.address;
    });
  }

  void _selectCustomAddress() {
    setState(() {
      _selectedAddressId = null;

      _nameController.clear();
      _phoneController.clear();
      _cityController.clear();
      _addressController.clear();
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cart = CartController.instance;

    if (cart.items.isEmpty) return;

    setState(() {
      _isPlacingOrder = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    final orderItems = cart.items
        .map(
          (item) => OrderItem(
            name: item.name,
            nameAr: item.nameAr,
            price: item.price,
            quantity: item.quantity,
            icon: item.icon,
            selectedSize: item.selectedSize,
            selectedColor: item.selectedColor,
          ),
        )
        .toList();

    final order = OrderController.instance.createOrder(
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      items: orderItems,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      total: cart.grandTotal,
    );

    cart.clearCart();

    setState(() {
      _isPlacingOrder = false;
    });

    final viewOrders = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          icon: Icon(
            Icons.check_circle_outline,
            size: 65,
            color: colors.primary,
          ),
          title: Text(
            _isArabic ? 'تم تأكيد طلبك بنجاح!' : 'Order Placed Successfully!',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isArabic
                    ? 'شكرًا لك، ${order.customerName}.'
                    : 'Thank you, ${order.customerName}.',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _isArabic
                    ? 'رقم الطلب: ${order.id}'
                    : 'Order Number: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isArabic
                    ? 'تم حفظ طلبك وسيتم تجهيزه للتوصيل.'
                    : 'Your order has been saved and will be prepared for delivery.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(
                  _isArabic ? 'عرض طلباتي' : 'View My Orders',
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(
                  _isArabic ? 'متابعة التسوق' : 'Continue Shopping',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (viewOrders == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OrdersScreen(),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isArabic ? 'إتمام الشراء' : 'Checkout',
          style: AppTextStyles.headingSmall.copyWith(
            color: colors.onSurface,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: CartController.instance,
        builder: (context, child) {
          final cart = CartController.instance;

          if (cart.items.isEmpty) {
            return Center(
              child: Text(
                _isArabic ? 'سلة التسوق فارغة.' : 'Your cart is empty.',
              ),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isArabic ? 'معلومات التوصيل' : 'Delivery Information',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _buildSavedAddressesSection(colors),

                  const SizedBox(height: AppSpacing.lg),

                  _buildLabel(
                    _isArabic ? 'الاسم بالكامل' : 'Full Name',
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _nameController,
                    hint: _isArabic ? 'أدخل اسمك بالكامل' : 'Enter your full name',
                    icon: Icons.person_outline,
                    colors: colors,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _buildLabel(
                    _isArabic ? 'رقم الهاتف' : 'Phone Number',
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '01XXXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    colors: colors,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _isArabic
                            ? 'من فضلك أدخل رقم الهاتف'
                            : 'Please enter your phone number';
                      }

                      final phone = value.trim();

                      if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone)) {
                        return _isArabic
                            ? 'أدخل رقم هاتف مصري صحيحًا (11 رقم يبدأ بـ 010، 011، 012، 015)'
                            : 'Enter a valid Egyptian mobile number (starts with 010, 011, 012, or 015)';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _buildLabel(
                    _isArabic ? 'المدينة' : 'City',
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _cityController,
                    hint: _isArabic ? 'أدخل مدينتك (مثل: القاهرة)' : 'Enter your city (e.g. Cairo)',
                    icon: Icons.location_city_outlined,
                    colors: colors,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _buildLabel(
                    _isArabic ? 'العنوان بالتفصيل' : 'Full Address',
                    colors,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _addressController,
                    hint: _isArabic
                        ? 'الشارع، المبنى، الشقة...'
                        : 'Street, building, apartment...',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    colors: colors,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    _isArabic ? 'طريقة الدفع' : 'Payment Method',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                      border: Border.all(
                        color: colors.primary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.money,
                          size: 30,
                          color: colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isArabic ? 'الدفع عند الاستلام' : 'Cash on Delivery',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isArabic
                                    ? 'ادفع نقدًا عند استلام طلبك.'
                                    : 'Pay with cash upon arrival.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    _isArabic ? 'ملخص الطلب' : 'Order Summary',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.getDisplayName(_isArabic)} x${item.quantity}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (item.selectedSize != null)
                                  Text(
                                    _isArabic ? 'المقاس: ${item.selectedSize}' : 'Size: ${item.selectedSize}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            _formatPrice(item.itemTotal),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: AppSpacing.lg),

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
                        _formatPrice(cart.subtotal),
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
                        cart.isFreeDelivery
                            ? (_isArabic ? 'مجاني' : 'FREE')
                            : _formatPrice(cart.deliveryFee),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cart.isFreeDelivery ? Colors.green : colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isArabic ? 'الإجمالي النهائي' : 'Total',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        _formatPrice(cart.grandTotal),
                        style: AppTextStyles.headingSmall.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      child: _isPlacingOrder
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isArabic ? 'تأكيد الطلب' : 'Place Order',
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedAddressesSection(ColorScheme colors) {
    if (_isLoadingAddresses) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_savedAddresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _isArabic
                    ? 'لا توجد عناوين محفوظة. يمكنك إدخال عنوان التوصيل يدويًا.'
                    : 'No saved addresses. You can enter your delivery address manually.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isArabic ? 'اختر عنوان التوصيل' : 'Choose Delivery Address',
          style: AppTextStyles.bodyLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ..._savedAddresses.map(
          (address) {
            final isSelected = _selectedAddressId == address.id;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  AppSpacing.cardRadius,
                ),
                onTap: () => _selectAddress(address),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardRadius,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    address.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (address.isDefault) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _isArabic ? 'افتراضي' : 'Default',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              address.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${address.city} - ${address.address}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              address.phone,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: _selectCustomAddress,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: _selectedAddressId == null
                    ? colors.primary
                    : colors.outlineVariant,
                width: _selectedAddressId == null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedAddressId == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _selectedAddressId == null
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _isArabic
                        ? 'إدخال عنوان مختلف'
                        : 'Enter a different address',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_location_alt_outlined,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return _isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }

  Widget _buildLabel(String label, ColorScheme colors) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme colors,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return _isArabic
                  ? 'هذا الحقل مطلوب'
                  : 'This field is required';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.inputRadius,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}