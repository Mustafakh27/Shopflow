# ShopFlow — Firebase & Backend Integration Guide

## 1. Overview
ShopFlow is fully designed and architected to transition seamlessly from local storage (`SharedPreferences`) to Firebase (Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging) without requiring UI rewrites.

All data models (`Product`, `CartItem`, `OrderItem`, `CustomerOrder`, `CustomerAddress`, `UserModel`) implement bidirectional JSON serialization (`toJson()` and `fromJson()`) which map directly to Cloud Firestore document structures.

---

## 2. Prerequisites & Console Setup
1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/).
   - Create a project named `shopflow-production`.
2. **Android App Configuration**:
   - Package name: `com.mustafa.shopflow`
   - Download `google-services.json` and place it at: `android/app/google-services.json`.
   - In `android/build.gradle` (or `settings.gradle`), ensure Google Services classpath is included:
     ```gradle
     id "com.google.gms.google-services" version "4.4.2" apply false
     ```
   - In `android/app/build.gradle`, apply the plugin:
     ```gradle
     plugins {
         ...
         id "com.google.gms.google-services"
     }
     ```
3. **iOS App Configuration**:
   - Bundle identifier: `com.mustafa.shopflow`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

---

## 3. Required Flutter Dependencies
Add the official Firebase packages in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.12.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.3
  firebase_storage: ^12.4.2
  firebase_messaging: ^15.2.2
```

Initialize Firebase in `lib/main.dart`:
```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 4. Firestore Schema Design

### Collection: `users`
Document ID: `userId` (Firebase Auth UID)
```json
{
  "id": "usr_abc123",
  "name": "Ahmed Mostafa",
  "email": "ahmed@example.com",
  "phone": "01012345678",
  "createdAt": "2026-11-05T06:00:00Z"
}
```

### Subcollection: `users/{userId}/addresses`
Document ID: `addressId`
```json
{
  "id": "addr_123",
  "title": "Home",
  "name": "Ahmed Mostafa",
  "phone": "01012345678",
  "city": "Cairo",
  "address": "Street 9, Maadi, Apt 4B",
  "isDefault": true
}
```

### Collection: `products`
Document ID: `productId` (e.g. `prod-001`)
```json
{
  "id": "prod-001",
  "nameEn": "Classic T-Shirt",
  "nameAr": "تيشيرت كلاسيك",
  "category": "Men",
  "price": 450.0,
  "descriptionEn": "A comfortable classic 100% cotton T-shirt...",
  "descriptionAr": "تيشيرت كلاسيك مريح مصنوع من القطن الطبيعي...",
  "imageUrl": "https://storage.googleapis.com/.../tshirt.png",
  "availableSizes": ["S", "M", "L", "XL"],
  "availableColors": [4294967295, 4278190080],
  "stockQuantity": 15,
  "isFeatured": true,
  "isNewArrival": false,
  "isBestSeller": true
}
```

### Collection: `orders`
Document ID: `orderId` (e.g. `SF1730000000000`)
```json
{
  "id": "SF1730000000000",
  "userId": "usr_abc123",
  "customerName": "Ahmed Mostafa",
  "phone": "01012345678",
  "city": "Cairo",
  "address": "Street 9, Maadi, Apt 4B",
  "createdAt": "2026-11-05T06:00:00Z",
  "subtotal": 1300.0,
  "deliveryFee": 0.0,
  "total": 1300.0,
  "paymentMethod": "Cash on Delivery",
  "status": "Pending",
  "items": [
    {
      "name": "Classic T-Shirt",
      "nameAr": "تيشيرت كلاسيك",
      "price": 450.0,
      "quantity": 2,
      "selectedSize": "L",
      "selectedColor": 4278190080
    }
  ]
}
```

---

## 5. Security Rules (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products can be read by anyone (guests included), modified only by admin
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }

    // User profiles and addresses
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /addresses/{addressId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Orders: Users can read their own orders; guests can create with COD
    match /orders/{orderId} {
      allow create: if true;
      allow read: if request.auth != null && (resource.data.userId == request.auth.uid || request.auth.token.admin == true);
      allow update: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

---

## 6. Migration Checklist
- [ ] Connect Firebase project in Google Cloud / Firebase Console.
- [ ] Add `google-services.json` to `android/app/`.
- [ ] Add `GoogleService-Info.plist` to `ios/Runner/`.
- [ ] Swap `AuthController` mock session for `FirebaseAuth.instance`.
- [ ] Replace `ProductCatalog` static list with Firestore stream subscription.
- [ ] Sync `OrderController.createOrder` to `FirebaseFirestore.instance.collection('orders').add(...)`.
- [ ] Configure Firebase Cloud Messaging (FCM) background handler for order status push notifications.
