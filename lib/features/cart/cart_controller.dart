import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_icons.dart';

class CartItem {
  final String? productId;
  final String name;
  final String? nameAr;
  final double price;
  final IconData icon;
  final String? selectedSize;
  final int? selectedColor;
  final int maxStock;
  int quantity;

  CartItem({
    this.productId,
    required this.name,
    this.nameAr,
    required this.price,
    required this.icon,
    this.selectedSize,
    this.selectedColor,
    this.maxStock = 99,
    this.quantity = 1,
  });

  String getDisplayName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  double get itemTotal => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'nameAr': nameAr,
      'price': price,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'maxStock': maxStock,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String?,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num).toDouble(),
      icon: AppIcons.getIcon(
        json['iconName'] as String?,
        json['iconCodePoint'] as int?,
      ),
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as int?,
      maxStock: json['maxStock'] as int? ?? 99,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  static const String _storageKey = 'shopflow_cart';
  static const double standardDeliveryFee = 50.0;
  static const double freeDeliveryThreshold = 1000.0;

  final List<CartItem> _items = [];
  bool _isLoaded = false;

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isLoaded => _isLoaded;

  int get itemCount =>
      _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal => _items.fold(
    0.0,
    (total, item) => total + (item.price * item.quantity),
  );

  // Backward-compatible alias
  double get totalPrice => subtotal;

  bool get isFreeDelivery => subtotal >= freeDeliveryThreshold && _items.isNotEmpty;

  double get deliveryFee {
    if (_items.isEmpty) return 0.0;
    return isFreeDelivery ? 0.0 : standardDeliveryFee;
  }

  double get grandTotal => subtotal + deliveryFee;

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null) {
        final decoded = jsonDecode(savedData) as List;
        _items.clear();
        for (final item in decoded) {
          try {
            _items.add(CartItem.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (_) {}
        }
      }
    } catch (_) {
      // Safe fallback
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  void addProduct({
    String? productId,
    required String name,
    String? nameAr,
    required double price,
    required IconData icon,
    String? selectedSize,
    int? selectedColor,
    int maxStock = 99,
    int quantity = 1,
  }) {
    // Check if same product with same size/color exists
    final index = _items.indexWhere(
      (item) =>
          item.name == name &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (index != -1) {
      final newQuantity = _items[index].quantity + quantity;
      _items[index].quantity = newQuantity.clamp(1, _items[index].maxStock);
    } else {
      _items.add(
        CartItem(
          productId: productId,
          name: name,
          nameAr: nameAr,
          price: price,
          icon: icon,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          maxStock: maxStock,
          quantity: quantity.clamp(1, maxStock),
        ),
      );
    }

    notifyListeners();
    _saveCart();
  }

  bool increaseQuantity(CartItem item) {
    if (item.quantity < item.maxStock) {
      item.quantity++;
      notifyListeners();
      _saveCart();
      return true;
    }
    return false;
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
    _saveCart();
  }

  void removeProduct(CartItem item) {
    _items.remove(item);
    notifyListeners();
    _saveCart();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
