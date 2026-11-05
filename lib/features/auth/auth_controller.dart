import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class AuthController extends ChangeNotifier {
  AuthController._();

  static final AuthController instance = AuthController._();

  static const String _sessionUserKey = 'shopflow_session_user';

  UserModel? _currentUser;
  bool _isLoaded = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser == null;
  bool get isLoaded => _isLoaded;

  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_sessionUserKey);
      if (userData != null) {
        _currentUser = UserModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(userData) as Map),
        );
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setSessionUser(UserModel user) async {
    _currentUser = user;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionUserKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionUserKey);
    } catch (_) {}
  }
}
