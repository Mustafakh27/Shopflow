# ShopFlow 🛍️

**A Modern Fashion & Accessories E-Commerce Mobile Application**

ShopFlow is a Flutter-based e-commerce mobile application designed to provide a clean, modern, and convenient shopping experience for fashion and accessories customers.

The application supports Arabic and English, Light and Dark themes, and a complete local shopping workflow.

## ✨ Features

### Shopping Experience
- Browse products and product details.
- Shopping cart management.
- Add and remove wishlist items.
- Quantity management and price calculations.
- Checkout with Cash on Delivery.
- Order creation and order history.

### Address Management
- Add, edit, and delete delivery addresses.
- Save multiple addresses.
- Set a default delivery address.
- Select saved addresses during checkout.

### Personalization
- Arabic and English language support.
- RTL and LTR layout support.
- Light and Dark themes.
- System theme preference.
- Persistent user preferences.

### Local Data Management
- Local cart persistence.
- Local wishlist persistence.
- Local order history.
- Saved delivery addresses.
- Persistent language and theme preferences.

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Local Storage:** SharedPreferences
- **UI:** Material Design
- **State Management:** Lightweight Flutter state management
- **Development Tools:** Android Studio, Git, GitHub

## 📱 Screens & Modules

- Home
- Products
- Product Details
- Wishlist
- Shopping Cart
- Checkout
- Orders
- Profile
- Address Management
- Settings

## 🌍 Localization

ShopFlow supports:

| Language | Layout Direction |
|---|---|
| English | LTR |
| Arabic | RTL |

## 🎨 Themes

- Light Mode
- Dark Mode
- System Default

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or a physical Android device

### Installation

Clone the repository:

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

Navigate to the project directory:

```bash
cd Shopflow
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## 🧪 Testing & Build

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android Debug APK:

```bash
flutter build apk --debug
```

Build Android Release APK:

```bash
flutter build apk --release
```

## 🔌 Backend Integration

The current version uses mock product data and local storage.

Firebase integration is planned for future development, including:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

These services are not currently presented as active integrations.

## 📌 Project Status

The core shopping experience is implemented and has been tested on an Android emulator.

The project is being prepared for future backend integration and further development.

## 👨‍💻 Developer

Developed as a Flutter e-commerce portfolio project.

---

**ShopFlow — A Simple and Modern Shopping Experience.**