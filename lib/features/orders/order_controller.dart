import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_icons.dart';

class OrderItem {
  final String name;
  final String? nameAr;
  final double price;
  final int quantity;
  final IconData icon;
  final String? selectedSize;
  final int? selectedColor;

  const OrderItem({
    required this.name,
    this.nameAr,
    required this.price,
    required this.quantity,
    required this.icon,
    this.selectedSize,
    this.selectedColor,
  });

  double get total => price * quantity;

  String getDisplayName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameAr': nameAr,
      'price': price,
      'quantity': quantity,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      icon: AppIcons.getIcon(
        json['iconName'] as String?,
        json['iconCodePoint'] as int?,
      ),
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as int?,
    );
  }
}

class CustomerOrder {
  final String id;
  final String customerName;
  final String phone;
  final String city;
  final String address;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  String status;

  CustomerOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.address,
    required this.createdAt,
    required this.items,
    double? subtotal,
    this.deliveryFee = 0.0,
    required this.total,
    required this.paymentMethod,
    this.status = 'Pending',
  }) : subtotal = subtotal ?? (total - deliveryFee);

  bool get canBeCancelled => status == 'Pending' || status == 'Confirmed';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'city': city,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return CustomerOrder(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      items: rawItems
          .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on Delivery',
      status: json['status'] as String? ?? 'Pending',
    );
  }
}

class OrderController extends ChangeNotifier {
  OrderController._();

  static final OrderController instance = OrderController._();

  static const String _storageKey = 'shopflow_orders';

  final List<CustomerOrder> _orders = [];
  bool _isLoaded = false;

  List<CustomerOrder> get orders => List.unmodifiable(_orders);

  bool get isLoaded => _isLoaded;

  Future<void> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null) {
        final decoded = jsonDecode(savedData) as List;
        _orders.clear();
        for (final item in decoded) {
          try {
            _orders.add(
              CustomerOrder.fromJson(Map<String, dynamic>.from(item as Map)),
            );
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

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  CustomerOrder createOrder({
    required String customerName,
    required String phone,
    required String city,
    required String address,
    required List<OrderItem> items,
    double? subtotal,
    double deliveryFee = 0.0,
    required double total,
    String paymentMethod = 'Cash on Delivery',
  }) {
    final order = CustomerOrder(
      id: 'SF${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      phone: phone,
      city: city,
      address: address,
      createdAt: DateTime.now(),
      items: List.unmodifiable(items),
      subtotal: subtotal ?? (total - deliveryFee),
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      status: 'Pending',
    );

    _orders.insert(0, order);
    notifyListeners();
    _saveOrders();

    return order;
  }

  void updateOrderStatus(CustomerOrder order, String status) {
    final index = _orders.indexWhere((o) => o.id == order.id);

    if (index == -1) return;

    _orders[index].status = status;
    notifyListeners();
    _saveOrders();
  }

  bool cancelOrder(CustomerOrder order) {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1 && _orders[index].canBeCancelled) {
      _orders[index].status = 'Cancelled';
      notifyListeners();
      _saveOrders();
      return true;
    }
    return false;
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
    _saveOrders();
  }
}
