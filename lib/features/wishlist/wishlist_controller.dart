import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_icons.dart';
import '../products/models/product.dart';

class WishlistItem {
  final String? productId;
  final String name;
  final String? nameAr;
  final String category;
  final double price;
  final String description;
  final String? descriptionAr;
  final IconData icon;

  const WishlistItem({
    this.productId,
    required this.name,
    this.nameAr,
    required this.category,
    required this.price,
    required this.description,
    this.descriptionAr,
    required this.icon,
  });

  String getDisplayName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  factory WishlistItem.fromProduct(Product product) {
    return WishlistItem(
      productId: product.id,
      name: product.nameEn,
      nameAr: product.nameAr,
      category: product.category,
      price: product.price,
      description: product.descriptionEn,
      descriptionAr: product.descriptionAr,
      icon: product.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'nameAr': nameAr,
      'category': category,
      'price': price,
      'description': description,
      'descriptionAr': descriptionAr,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      productId: json['productId'] as String?,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      descriptionAr: json['descriptionAr'] as String?,
      icon: AppIcons.getIcon(
        json['iconName'] as String?,
        json['iconCodePoint'] as int?,
      ),
    );
  }
}

class WishlistController extends ChangeNotifier {
  WishlistController._();

  static final WishlistController instance = WishlistController._();

  static const String _storageKey = 'shopflow_wishlist';

  final List<WishlistItem> _items = [];
  bool _isLoaded = false;

  List<WishlistItem> get items => List.unmodifiable(_items);

  bool get isLoaded => _isLoaded;

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null) {
        final decoded = jsonDecode(savedData) as List;
        _items.clear();
        for (final item in decoded) {
          try {
            _items.add(
              WishlistItem.fromJson(Map<String, dynamic>.from(item as Map)),
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

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  bool isFavorite(String identifier) {
    return _items.any(
      (item) => item.name == identifier || item.productId == identifier,
    );
  }

  void toggleProduct(WishlistItem product) {
    if (isFavorite(product.productId ?? product.name)) {
      _items.removeWhere(
        (item) =>
            item.name == product.name ||
            (product.productId != null && item.productId == product.productId),
      );
    } else {
      _items.add(product);
    }

    notifyListeners();
    _saveWishlist();
  }

  void toggleFromProduct(Product product) {
    toggleProduct(WishlistItem.fromProduct(product));
  }

  void removeProduct(String identifier) {
    _items.removeWhere(
      (item) => item.name == identifier || item.productId == identifier,
    );
    notifyListeners();
    _saveWishlist();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
    _saveWishlist();
  }
}
