import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopflow/features/cart/cart_controller.dart';
import 'package:shopflow/features/orders/order_controller.dart';
import 'package:shopflow/features/products/data/product_catalog.dart';
import 'package:shopflow/features/products/models/product.dart';
import 'package:shopflow/features/profile/presentation/screens/addresses_screen.dart';
import 'package:shopflow/features/wishlist/wishlist_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CartController.instance.clearCart();
    WishlistController.instance.clearWishlist();
    OrderController.instance.clearOrders();
  });

  group('ProductCatalog & Product Model Tests', () {
    test('Catalog contains rich collection of products', () {
      final all = ProductCatalog.getAll();
      expect(all.length, greaterThanOrEqualTo(12));
      for (final p in all) {
        expect(p.id.isNotEmpty, true);
        expect(p.nameEn.isNotEmpty, true);
        expect(p.nameAr.isNotEmpty, true);
        expect(p.price, greaterThan(0));
        expect(p.stockQuantity, greaterThan(0));
      }
    });

    test('Category filtering works correctly', () {
      final men = ProductCatalog.filter(category: 'Men');
      expect(men.every((p) => p.category == 'Men'), true);

      final women = ProductCatalog.filter(category: 'Women');
      expect(women.every((p) => p.category == 'Women'), true);

      final shoes = ProductCatalog.filter(category: 'Shoes');
      expect(shoes.every((p) => p.category == 'Shoes'), true);

      final accessories = ProductCatalog.filter(category: 'Accessories');
      expect(accessories.every((p) => p.category == 'Accessories'), true);
    });

    test('Bilingual search matches English and Arabic titles', () {
      final searchEn = ProductCatalog.filter(query: 'shirt');
      expect(searchEn.any((p) => p.id == 'prod-001'), true);

      final searchAr = ProductCatalog.filter(query: 'تيشيرت');
      expect(searchAr.any((p) => p.id == 'prod-001'), true);
    });

    test('Sorting by price low to high and high to low', () {
      final lowToHigh = ProductCatalog.filter(sort: ProductSortOption.priceLowToHigh);
      for (int i = 0; i < lowToHigh.length - 1; i++) {
        expect(lowToHigh[i].price <= lowToHigh[i + 1].price, true);
      }

      final highToLow = ProductCatalog.filter(sort: ProductSortOption.priceHighToLow);
      for (int i = 0; i < highToLow.length - 1; i++) {
        expect(highToLow[i].price >= highToLow[i + 1].price, true);
      }
    });

    test('Product JSON serialization and deserialization', () {
      final original = ProductCatalog.getAll().first;
      final json = original.toJson();
      final restored = Product.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.nameEn, original.nameEn);
      expect(restored.nameAr, original.nameAr);
      expect(restored.price, original.price);
      expect(restored.category, original.category);
    });
  });

  group('CartController Tests', () {
    test('Adding products increases count and calculates subtotal', () {
      final cart = CartController.instance;
      expect(cart.itemCount, 0);

      cart.addProduct(
        productId: 'prod-001',
        name: 'Classic T-Shirt',
        nameAr: 'تيشيرت كلاسيك',
        price: 450,
        icon: Icons.checkroom,
        selectedSize: 'M',
        maxStock: 5,
        quantity: 2,
      );

      expect(cart.itemCount, 2);
      expect(cart.subtotal, 900);
      // Below 1000 threshold -> standard delivery fee applies
      expect(cart.isFreeDelivery, false);
      expect(cart.deliveryFee, 50);
      expect(cart.grandTotal, 950);
    });

    test('Free delivery applies when subtotal reaches or exceeds 1000 EGP', () {
      final cart = CartController.instance;

      cart.addProduct(
        productId: 'prod-002',
        name: 'Casual Sneakers',
        nameAr: 'حذاء رياضي كاجوال',
        price: 1200,
        icon: Icons.directions_walk,
        quantity: 1,
      );

      expect(cart.subtotal, 1200);
      expect(cart.isFreeDelivery, true);
      expect(cart.deliveryFee, 0.0);
      expect(cart.grandTotal, 1200);
    });

    test('Quantity update respects maxStock boundary', () {
      final cart = CartController.instance;

      cart.addProduct(
        productId: 'prod-001',
        name: 'Classic T-Shirt',
        price: 450,
        icon: Icons.checkroom,
        maxStock: 2,
        quantity: 1,
      );

      final item = cart.items.first;
      final success1 = cart.increaseQuantity(item);
      expect(success1, true);
      expect(item.quantity, 2);

      // Exceeds max stock (2)
      final success2 = cart.increaseQuantity(item);
      expect(success2, false);
      expect(item.quantity, 2);
    });

    test('Decreasing quantity down to 0 removes the item', () {
      final cart = CartController.instance;

      cart.addProduct(
        name: 'Watch',
        price: 850,
        icon: Icons.watch,
        quantity: 1,
      );
      expect(cart.items.length, 1);

      cart.decreaseQuantity(cart.items.first);
      expect(cart.items.length, 0);
      expect(cart.deliveryFee, 0.0);
    });

    test('CartItem JSON serialization', () {
      final item = CartItem(
        productId: 'p1',
        name: 'Sneakers',
        nameAr: 'حذاء',
        price: 1200,
        icon: Icons.directions_walk,
        selectedSize: '42',
        selectedColor: 0xFFFFFFFF,
        maxStock: 10,
        quantity: 2,
      );

      final json = item.toJson();
      final restored = CartItem.fromJson(json);

      expect(restored.productId, 'p1');
      expect(restored.name, 'Sneakers');
      expect(restored.nameAr, 'حذاء');
      expect(restored.price, 1200);
      expect(restored.selectedSize, '42');
      expect(restored.quantity, 2);
    });
  });

  group('WishlistController Tests', () {
    test('Toggle adds and removes items', () {
      final wishlist = WishlistController.instance;
      final product = ProductCatalog.getAll().first;

      expect(wishlist.isFavorite(product.id), false);

      wishlist.toggleFromProduct(product);
      expect(wishlist.isFavorite(product.id), true);
      expect(wishlist.items.length, 1);

      wishlist.toggleFromProduct(product);
      expect(wishlist.isFavorite(product.id), false);
      expect(wishlist.items.isEmpty, true);
    });

    test('WishlistItem JSON serialization', () {
      const item = WishlistItem(
        productId: 'w1',
        name: 'Dress',
        nameAr: 'فستان',
        category: 'Women',
        price: 950,
        description: 'Summer dress',
        icon: Icons.checkroom,
      );

      final json = item.toJson();
      final restored = WishlistItem.fromJson(json);

      expect(restored.productId, 'w1');
      expect(restored.name, 'Dress');
      expect(restored.nameAr, 'فستان');
      expect(restored.price, 950);
    });
  });

  group('OrderController Tests', () {
    test('Creating order generates ID, stores details and status Pending', () {
      final orderController = OrderController.instance;

      final order = orderController.createOrder(
        customerName: 'Mohamed Ali',
        phone: '01012345678',
        city: 'Alexandria',
        address: 'Stanley, Cornish Road',
        items: const [
          OrderItem(
            name: 'Classic T-Shirt',
            nameAr: 'تيشيرت كلاسيك',
            price: 450,
            quantity: 2,
            icon: Icons.checkroom,
            selectedSize: 'L',
          ),
        ],
        subtotal: 900,
        deliveryFee: 50,
        total: 950,
      );

      expect(order.id.startsWith('SF'), true);
      expect(order.customerName, 'Mohamed Ali');
      expect(order.status, 'Pending');
      expect(order.canBeCancelled, true);
      expect(order.subtotal, 900);
      expect(order.deliveryFee, 50);
      expect(order.total, 950);
    });

    test('Order can be cancelled when pending', () {
      final orderController = OrderController.instance;

      final order = orderController.createOrder(
        customerName: 'Sara Ahmed',
        phone: '01123456789',
        city: 'Giza',
        address: 'Dokki, Street 15',
        items: const [
          OrderItem(
            name: 'Handbag',
            price: 1100,
            quantity: 1,
            icon: Icons.shopping_bag,
          ),
        ],
        total: 1100,
      );

      final cancelled = orderController.cancelOrder(order);
      expect(cancelled, true);
      expect(order.status, 'Cancelled');
      expect(order.canBeCancelled, false);
    });

    test('Order JSON serialization preserves full breakdown', () {
      final order = CustomerOrder(
        id: 'SF123456',
        customerName: 'Test User',
        phone: '01234567890',
        city: 'Cairo',
        address: 'Nasr City',
        createdAt: DateTime(2026, 11, 5),
        items: const [
          OrderItem(
            name: 'Sneakers',
            price: 1200,
            quantity: 1,
            icon: Icons.directions_walk,
            selectedSize: '43',
          ),
        ],
        subtotal: 1200,
        deliveryFee: 0,
        total: 1200,
        paymentMethod: 'Cash on Delivery',
      );

      final json = order.toJson();
      final restored = CustomerOrder.fromJson(json);

      expect(restored.id, 'SF123456');
      expect(restored.customerName, 'Test User');
      expect(restored.items.length, 1);
      expect(restored.items.first.name, 'Sneakers');
      expect(restored.items.first.selectedSize, '43');
      expect(restored.subtotal, 1200);
      expect(restored.total, 1200);
    });
  });

  group('CustomerAddress Tests', () {
    test('Address serialization and default flag', () {
      const address = CustomerAddress(
        id: 'addr_001',
        title: 'Home',
        name: 'Ahmed',
        phone: '01012345678',
        city: 'Cairo',
        address: 'Zamalek, Brazil St.',
        isDefault: true,
      );

      final json = address.toJson();
      final restored = CustomerAddress.fromJson(json);

      expect(restored.id, 'addr_001');
      expect(restored.title, 'Home');
      expect(restored.name, 'Ahmed');
      expect(restored.city, 'Cairo');
      expect(restored.isDefault, true);
    });
  });

  group('Egyptian Phone Validation Tests', () {
    final validPhones = [
      '01012345678',
      '01123456789',
      '01234567890',
      '01512345678',
    ];

    final invalidPhones = [
      '02012345678', // does not start with 01
      '0101234567',  // 10 digits
      '010123456789', // 12 digits
      '01312345678',  // not a valid mobile operator prefix (010, 011, 012, 015)
      'abcdefghijk',
    ];

    final regex = RegExp(r'^01[0125][0-9]{8}$');

    for (final phone in validPhones) {
      test('Valid phone: $phone', () {
        expect(regex.hasMatch(phone), true);
      });
    }

    for (final phone in invalidPhones) {
      test('Invalid phone: $phone', () {
        expect(regex.hasMatch(phone), false);
      });
    }
  });
}
