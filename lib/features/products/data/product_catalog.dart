import 'package:flutter/material.dart';
import '../models/product.dart';

enum ProductSortOption {
  featured,
  priceLowToHigh,
  priceHighToLow,
  newest,
  bestSellers,
  nameAsc;

  String getLabel(bool isArabic) {
    if (!isArabic) {
      switch (this) {
        case ProductSortOption.featured:
          return 'Featured';
        case ProductSortOption.priceLowToHigh:
          return 'Price: Low to High';
        case ProductSortOption.priceHighToLow:
          return 'Price: High to Low';
        case ProductSortOption.newest:
          return 'Newest Arrivals';
        case ProductSortOption.bestSellers:
          return 'Best Sellers';
        case ProductSortOption.nameAsc:
          return 'Name: A to Z';
      }
    } else {
      switch (this) {
        case ProductSortOption.featured:
          return 'المميزة';
        case ProductSortOption.priceLowToHigh:
          return 'السعر: من الأقل للأعلى';
        case ProductSortOption.priceHighToLow:
          return 'السعر: من الأعلى للأقل';
        case ProductSortOption.newest:
          return 'الأحدث وصولاً';
        case ProductSortOption.bestSellers:
          return 'الأكثر مبيعاً';
        case ProductSortOption.nameAsc:
          return 'الاسم: أ إلى ي';
      }
    }
  }
}

class ProductCatalog {
  ProductCatalog._();

  static const List<Product> products = [
    Product(
      id: 'prod-001',
      nameEn: 'Classic T-Shirt',
      nameAr: 'تيشيرت كلاسيك',
      category: 'Men',
      price: 450,
      descriptionEn: 'A comfortable classic 100% cotton T-shirt tailored for everyday premium wear.',
      descriptionAr: 'تيشيرت كلاسيك مريح مصنوع من القطن الطبيعي 100% ومصمم للاستخدام اليومي الراقي.',
      icon: Icons.checkroom,
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableColors: [0xFFFFFFFF, 0xFF212121, 0xFF1A237E, 0xFF33691E],
      stockQuantity: 15,
      isFeatured: true,
      isNewArrival: false,
      isBestSeller: true,
    ),
    Product(
      id: 'prod-002',
      nameEn: 'Casual Sneakers',
      nameAr: 'حذاء رياضي كاجوال',
      category: 'Shoes',
      price: 1200,
      descriptionEn: 'Modern casual sneakers with cushioned insoles for superior all-day walking comfort.',
      descriptionAr: 'حذاء رياضي عصري مع بطانة مريحة توفر أقصى درجات الراحة طوال اليوم.',
      icon: Icons.directions_walk,
      availableSizes: ['40', '41', '42', '43', '44'],
      availableColors: [0xFFFFFFFF, 0xFF757575, 0xFF212121],
      stockQuantity: 8,
      isFeatured: true,
      isNewArrival: false,
      isBestSeller: true,
    ),
    Product(
      id: 'prod-003',
      nameEn: 'Leather Watch',
      nameAr: 'ساعة جلد',
      category: 'Accessories',
      price: 850,
      descriptionEn: 'A minimalist analogue watch featuring genuine leather strap and scratch-resistant glass.',
      descriptionAr: 'ساعة يد كلاسيكية بتصميم بسيط وأنيق مع سوار من الجلد الطبيعي وزجاج مقاوم للخدش.',
      icon: Icons.watch,
      availableSizes: ['Standard'],
      availableColors: [0xFF5D4037, 0xFF212121, 0xFFC5A059],
      stockQuantity: 12,
      isFeatured: true,
      isNewArrival: true,
      isBestSeller: true,
    ),
    Product(
      id: 'prod-004',
      nameEn: 'Summer Dress',
      nameAr: 'فستان صيفي',
      category: 'Women',
      price: 950,
      descriptionEn: 'An elegant lightweight dress with breathable linen fabric, perfect for sunny summer outings.',
      descriptionAr: 'فستان صيفي أنيق وخفيف مصنوع من قماش الكتان المريح، مثالي للأيام الدافئة.',
      icon: Icons.checkroom,
      availableSizes: ['S', 'M', 'L'],
      availableColors: [0xFFE0F2FE, 0xFFFEE2E2, 0xFFFFFBEB],
      stockQuantity: 6,
      isFeatured: true,
      isNewArrival: true,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-005',
      nameEn: 'Casual Hoodie',
      nameAr: 'هودي كاجوال',
      category: 'Men',
      price: 750,
      descriptionEn: 'Soft premium fleece hoodie with front kangaroo pocket and adjustable drawstring hood.',
      descriptionAr: 'هودي ناعم مصنوع من الصوف عالي الجودة مع جيب أمامي وغطاء رأس برباط قابل للتعديل.',
      icon: Icons.checkroom,
      availableSizes: ['M', 'L', 'XL', 'XXL'],
      availableColors: [0xFF9E9E9E, 0xFF212121, 0xFF2E7D32],
      stockQuantity: 20,
      isFeatured: false,
      isNewArrival: false,
      isBestSeller: true,
    ),
    Product(
      id: 'prod-006',
      nameEn: 'Handbag',
      nameAr: 'حقيبة يد',
      category: 'Accessories',
      price: 1100,
      descriptionEn: 'A stylish structured leather handbag with spacious compartments and detachable shoulder strap.',
      descriptionAr: 'حقيبة يد أنيقة من الجلد الفاخر مع جيوب منظمة وحزام كتف قابل للإزالة.',
      icon: Icons.shopping_bag_outlined,
      availableSizes: ['Standard'],
      availableColors: [0xFF4E342E, 0xFF212121, 0xFFD7CCC8],
      stockQuantity: 5,
      isFeatured: true,
      isNewArrival: false,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-007',
      nameEn: 'Running Shoes',
      nameAr: 'حذاء جري',
      category: 'Shoes',
      price: 1450,
      descriptionEn: 'High-performance ultra-lightweight running shoes engineered for responsive cushioning.',
      descriptionAr: 'حذاء جري فائق الخفة وعالي الأداء مصمم بامتصاص صدمات متطور لحماية القدم.',
      icon: Icons.directions_run,
      availableSizes: ['40', '41', '42', '43', '44', '45'],
      availableColors: [0xFF0284C7, 0xFF374151, 0xFFDC2626],
      stockQuantity: 10,
      isFeatured: false,
      isNewArrival: true,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-008',
      nameEn: 'Women Top',
      nameAr: 'توب حريمي',
      category: 'Women',
      price: 550,
      descriptionEn: 'A versatile chic sleeveless top crafted from breathable organic cotton blend.',
      descriptionAr: 'توب حريمي أنيق وعملي بدون أكمام مصنوع من مزيج القطن العضوي المريح.',
      icon: Icons.checkroom,
      availableSizes: ['XS', 'S', 'M', 'L'],
      availableColors: [0xFFFAFAFA, 0xFF84CC16, 0xFFF97316],
      stockQuantity: 14,
      isFeatured: false,
      isNewArrival: false,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-009',
      nameEn: 'Slim Chinos',
      nameAr: 'بنطلون تشينو عصري',
      category: 'Men',
      price: 850,
      descriptionEn: 'Smart casual slim-fit chinos crafted with stretch cotton twill for all-day flexibility.',
      descriptionAr: 'بنطلون تشينو عصري أنيق بقصة ملائمة ومصنوع من القطن المرن لسهولة الحركة.',
      icon: Icons.checkroom,
      availableSizes: ['30', '32', '34', '36'],
      availableColors: [0xFFD2B48C, 0xFF1E3A8A, 0xFF374151],
      stockQuantity: 18,
      isFeatured: false,
      isNewArrival: true,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-010',
      nameEn: 'Retro Sunglasses',
      nameAr: 'نظارة شمسية كلاسيكية',
      category: 'Accessories',
      price: 600,
      descriptionEn: 'Polarized UV400 protective sunglasses with handcrafted acetate vintage frame.',
      descriptionAr: 'نظارة شمسية كلاسيكية بعدسات مستقطبة وحماية UV400 مع إطار أسيتات عتيق أنيق.',
      icon: Icons.wb_sunny_outlined,
      availableSizes: ['Standard'],
      availableColors: [0xFF1C1917, 0xFF78350F, 0xFFD4AF37],
      stockQuantity: 9,
      isFeatured: false,
      isNewArrival: false,
      isBestSeller: true,
    ),
    Product(
      id: 'prod-011',
      nameEn: 'Leather Oxford Shoes',
      nameAr: 'حذاء أكسفورد كلاسيكي',
      category: 'Shoes',
      price: 1850,
      descriptionEn: 'Hand-burnished Italian leather formal Oxford shoes for executive and evening elegance.',
      descriptionAr: 'حذاء أكسفورد رسمي فاخر مصنوع يدوياً من الجلد الطبيعي للإطلالات الرسمية الراقية.',
      icon: Icons.work_outline,
      availableSizes: ['41', '42', '43', '44'],
      availableColors: [0xFF3E2723, 0xFF1B1B1B],
      stockQuantity: 4,
      isFeatured: false,
      isNewArrival: false,
      isBestSeller: false,
    ),
    Product(
      id: 'prod-012',
      nameEn: 'High-Waist Jeans',
      nameAr: 'جينز عالي الخصر',
      category: 'Women',
      price: 900,
      descriptionEn: 'Classic high-rise straight-leg denim jeans with authentic vintage wash and comfortable stretch.',
      descriptionAr: 'بنطلون جينز بخصر عالي وقصة مستقيمة مع غسيل كلاسيكي مميز ومرونة مريحة.',
      icon: Icons.checkroom,
      availableSizes: ['26', '28', '30', '32'],
      availableColors: [0xFF1E40AF, 0xFF1F2937, 0xFF60A5FA],
      stockQuantity: 11,
      isFeatured: false,
      isNewArrival: true,
      isBestSeller: false,
    ),
  ];

  static List<Product> getAll() => List.unmodifiable(products);

  static Product? getById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static Product? getByName(String name) {
    try {
      return products.firstWhere((p) => p.nameEn == name || p.nameAr == name);
    } catch (_) {
      return null;
    }
  }

  static List<Product> getFeatured() =>
      products.where((p) => p.isFeatured).toList();

  static List<Product> getNewArrivals() =>
      products.where((p) => p.isNewArrival).toList();

  static List<Product> getBestSellers() =>
      products.where((p) => p.isBestSeller).toList();

  static List<Product> getRelated(Product product) {
    return products
        .where((p) => p.id != product.id && p.category == product.category)
        .take(4)
        .toList();
  }

  static List<Product> filter({
    String query = '',
    String category = 'All',
    ProductSortOption sort = ProductSortOption.featured,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    var results = products.where((p) {
      final matchesCategory = category == 'All' || p.category == category;
      final matchesSearch = cleanQuery.isEmpty ||
          p.nameEn.toLowerCase().contains(cleanQuery) ||
          p.nameAr.toLowerCase().contains(cleanQuery) ||
          p.category.toLowerCase().contains(cleanQuery) ||
          p.descriptionEn.toLowerCase().contains(cleanQuery) ||
          p.descriptionAr.toLowerCase().contains(cleanQuery);

      return matchesCategory && matchesSearch;
    }).toList();

    switch (sort) {
      case ProductSortOption.priceLowToHigh:
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.newest:
        results.sort((a, b) => (b.isNewArrival ? 1 : 0).compareTo(a.isNewArrival ? 1 : 0));
        break;
      case ProductSortOption.bestSellers:
        results.sort((a, b) => (b.isBestSeller ? 1 : 0).compareTo(a.isBestSeller ? 1 : 0));
        break;
      case ProductSortOption.nameAsc:
        results.sort((a, b) => a.nameEn.compareTo(b.nameEn));
        break;
      case ProductSortOption.featured:
        results.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
        break;
    }

    return results;
  }
}
