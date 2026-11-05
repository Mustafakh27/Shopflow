import 'package:flutter/material.dart';

import '../../../../core/language/language_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/cart_controller.dart';
import '../../../wishlist/wishlist_controller.dart';
import '../../data/product_catalog.dart';
import '../../models/product.dart';

// Re-export for backward compatibility
export '../../models/product.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const ProductsScreen({
    super.key,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final TextEditingController _searchController;
  late String _selectedCategory;
  ProductSortOption _selectedSort = ProductSortOption.featured;

  final List<String> _categories = const [
    'All',
    'Men',
    'Women',
    'Shoes',
    'Accessories',
  ];

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedSort = ProductSortOption.featured;
    });
  }

  String _getCategoryName(String category) {
    if (!_isArabic) return category;
    switch (category) {
      case 'All':
        return 'الكل';
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

  String _formatPrice(double price) {
    return _isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }

  void _openSortBottomSheet(ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isArabic ? 'ترتيب حسب' : 'Sort By',
                  style: AppTextStyles.headingSmall.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...ProductSortOption.values.map((option) {
                  final isSelected = _selectedSort == option;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option.getLabel(_isArabic),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isSelected ? colors.primary : colors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: colors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSort = option;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final products = ProductCatalog.filter(
      query: _searchController.text,
      category: _selectedCategory,
      sort: _selectedSort,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isArabic ? 'اكتشف المنتجات' : 'Discover Products',
          style: AppTextStyles.headingSmall.copyWith(
            color: colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isArabic ? 'ترتيب' : 'Sort',
            onPressed: () => _openSortBottomSheet(colors),
            icon: const Icon(Icons.swap_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.xs,
              ),
              child: TextField(
                controller: _searchController,
                textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _isArabic ? 'ابحث عن المنتجات...' : 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Categories
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return ChoiceChip(
                    label: Text(_getCategoryName(category)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Products count and active filter indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isArabic
                        ? '${products.length} منتجات'
                        : '${products.length} items',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty || _selectedCategory != 'All' || _selectedSort != ProductSortOption.featured)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(
                        _isArabic ? 'إعادة ضبط' : 'Reset',
                        style: AppTextStyles.bodySmall.copyWith(color: colors.secondary),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Products Grid
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colors.secondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _isArabic ? 'لم يتم العثور على منتجات' : 'No products found',
                            style: AppTextStyles.headingSmall.copyWith(color: colors.onSurface),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _isArabic
                                ? 'جرب البحث بكلمات أخرى أو اختر تصنيفاً مختلفاً.'
                                : 'Try different keywords or clear your active filters.',
                            style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton.tonal(
                            onPressed: _clearFilters,
                            child: Text(_isArabic ? 'عرض جميع المنتجات' : 'View All Products'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.xs,
                        AppSpacing.screenPadding,
                        AppSpacing.xl,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return _ProductCard(
                          product: product,
                          isArabic: _isArabic,
                          priceFormatted: _formatPrice(product.price),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isArabic;
  final String priceFormatted;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.isArabic,
    required this.priceFormatted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Center(
                    child: Icon(
                      product.icon,
                      size: 54,
                      color: colors.secondary,
                    ),
                  ),
                ),
                // Wishlist quick-toggle
                PositionedDirectional(
                  top: AppSpacing.xs,
                  end: AppSpacing.xs,
                  child: AnimatedBuilder(
                    animation: WishlistController.instance,
                    builder: (context, _) {
                      final isFav = WishlistController.instance.isFavorite(product.id);
                      return IconButton(
                        iconSize: 20,
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
                if (product.isBestSeller || product.isNewArrival)
                  PositionedDirectional(
                    top: AppSpacing.xs,
                    start: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isBestSeller
                            ? (isArabic ? 'الأكثر مبيعاً' : 'Best Seller')
                            : (isArabic ? 'جديد' : 'New'),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  int? _selectedColor;
  int _quantity = 1;

  bool get _isArabic => LanguageController.instance.isArabic;

  @override
  void initState() {
    super.initState();
    if (widget.product.availableSizes.isNotEmpty) {
      _selectedSize = widget.product.availableSizes.first;
    }
    if (widget.product.availableColors.isNotEmpty) {
      _selectedColor = widget.product.availableColors.first;
    }
  }

  String _formatPrice(double price) {
    return _isArabic
        ? '${price.toStringAsFixed(0)} جنيه'
        : '${price.toStringAsFixed(0)} EGP';
  }

  void _addToCart() {
    final product = widget.product;
    if (!product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic ? 'عذرًا، المنتج غير متوفر حاليًا' : 'Sorry, product is currently out of stock',
          ),
        ),
      );
      return;
    }

    CartController.instance.addProduct(
      productId: product.id,
      name: product.nameEn,
      nameAr: product.nameAr,
      price: product.price,
      icon: product.icon,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
      maxStock: product.stockQuantity,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isArabic
              ? 'تمت إضافة (${product.getName(_isArabic)}) إلى السلة'
              : '${product.getName(_isArabic)} added to cart',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final product = widget.product;
    final related = ProductCatalog.getRelated(product);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isArabic ? 'تفاصيل المنتج' : 'Product Details'),
        actions: [
          AnimatedBuilder(
            animation: WishlistController.instance,
            builder: (context, _) {
              final isFavorite = WishlistController.instance.isFavorite(product.id);
              return IconButton(
                tooltip: isFavorite
                    ? (_isArabic ? 'إزالة من المفضلة' : 'Remove from Wishlist')
                    : (_isArabic ? 'إضافة إلى المفضلة' : 'Add to Wishlist'),
                onPressed: () {
                  WishlistController.instance.toggleFromProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? (_isArabic
                                ? 'تمت إزالة ${product.getName(_isArabic)} من المفضلة'
                                : '${product.getName(_isArabic)} removed from Wishlist')
                            : (_isArabic
                                ? 'تمت إضافة ${product.getName(_isArabic)} إلى المفضلة'
                                : '${product.getName(_isArabic)} added to Wishlist'),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? colors.error : colors.onSurface,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image Card
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Center(
                child: Icon(
                  product.icon,
                  size: 110,
                  color: colors.secondary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category & Stock Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.getCategoryName(_isArabic),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isInStock
                        ? Colors.green.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.isInStock
                        ? (_isArabic
                            ? 'متوفر (${product.stockQuantity} قطع)'
                            : 'In Stock (${product.stockQuantity} left)')
                        : (_isArabic ? 'غير متوفر' : 'Out of Stock'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: product.isInStock ? Colors.green : colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Product Name
            Text(
              product.getName(_isArabic),
              style: AppTextStyles.headingMedium.copyWith(
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Price
            Text(
              _formatPrice(product.price),
              style: AppTextStyles.price.copyWith(
                fontSize: 22,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Available Sizes
            if (product.availableSizes.isNotEmpty) ...[
              Text(
                _isArabic ? 'المقاس' : 'Size',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: product.availableSizes.map((size) {
                  final isSelected = _selectedSize == size;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSize = size);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Available Colors
            if (product.availableColors.isNotEmpty) ...[
              Text(
                _isArabic ? 'اللون' : 'Color',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: product.availableColors.map((colorValue) {
                  final isSelected = _selectedColor == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = colorValue);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(colorValue),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: Color(colorValue).computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Quantity Selector
            Row(
              children: [
                Text(
                  _isArabic ? 'الكمية' : 'Quantity',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 18,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text(
                          '$_quantity',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 18,
                        onPressed: _quantity < product.stockQuantity
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              _isArabic ? 'الوصف' : 'Description',
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              product.getDescription(_isArabic),
              style: AppTextStyles.bodyLarge.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: product.isInStock ? _addToCart : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  _isArabic ? 'أضف إلى السلة' : 'Add to Cart',
                  style: AppTextStyles.button,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Related Products
            if (related.isNotEmpty) ...[
              Text(
                _isArabic ? 'منتجات ذات صلة' : 'Related Products',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = related[index];
                    return SizedBox(
                      width: 140,
                      child: _ProductCard(
                        product: item,
                        isArabic: _isArabic,
                        priceFormatted: _formatPrice(item.price),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(product: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}
