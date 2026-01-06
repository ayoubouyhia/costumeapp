import 'package:flutter/material.dart';
// import 'package:dio/dio.dart'; // Uncomment when real API is reachable
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1)); 

    // In real app:
    // final response = await Dio().post('http://localhost:8000/api/login', data: {...});
    // _token = response.data['access_token'];

    if (email == 'test@example.com' && password == 'password') {
      _token = 'simulated_token_123';
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
