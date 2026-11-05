import 'package:flutter/material.dart';
import '../../../core/widgets/app_icons.dart';

class Product {
  final String id;
  final String nameEn;
  final String nameAr;
  final String category;
  final double price;
  final String descriptionEn;
  final String descriptionAr;
  final IconData icon;
  final String? imageUrl;
  final List<String> availableSizes;
  final List<int> availableColors;
  final int stockQuantity;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isBestSeller;

  const Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.price,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.icon,
    this.imageUrl,
    this.availableSizes = const [],
    this.availableColors = const [],
    this.stockQuantity = 10,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
  });

  bool get isInStock => stockQuantity > 0;

  // Backward compatibility alias for existing code
  String get name => nameEn;
  String get description => descriptionEn;

  String getName(bool isArabic) => isArabic ? nameAr : nameEn;
  String getDescription(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  String getCategoryName(bool isArabic) {
    if (!isArabic) return category;
    switch (category) {
      case 'Men':
        return 'رجالي';
      case 'Women':
        return 'حريمي';
      case 'Shoes':
        return 'أحذية';
      case 'Accessories':
        return 'إكسسوارات';
      default:
        return category;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'category': category,
      'price': price,
      'descriptionEn': descriptionEn,
      'descriptionAr': descriptionAr,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'imageUrl': imageUrl,
      'availableSizes': availableSizes,
      'availableColors': availableColors,
      'stockQuantity': stockQuantity,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      descriptionEn: json['descriptionEn'] as String,
      descriptionAr: json['descriptionAr'] as String,
      icon: AppIcons.getIcon(
        json['iconName'] as String?,
        json['iconCodePoint'] as int?,
      ),
      imageUrl: json['imageUrl'] as String?,
      availableSizes: (json['availableSizes'] as List?)?.cast<String>() ?? const [],
      availableColors: (json['availableColors'] as List?)?.cast<int>() ?? const [],
      stockQuantity: json['stockQuantity'] as int? ?? 10,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
    );
  }
}
