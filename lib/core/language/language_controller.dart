
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  LanguageController._();

  static final LanguageController instance = LanguageController._();

  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    _locale = savedLanguage == 'ar'
        ? const Locale('ar')
        : const Locale('en');

    notifyListeners();
  }

  Future<void> setLanguage(Locale locale) async {
    if (locale.languageCode != 'ar' &&
        locale.languageCode != 'en') {
      return;
    }

    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _languageKey,
      locale.languageCode,
    );
  }
}
