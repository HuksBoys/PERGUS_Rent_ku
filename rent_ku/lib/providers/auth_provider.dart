import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  final ApiService _apiService = ApiService();

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      _token = response.data['access_token'];
      _user = UserModel.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_role', _user!.role);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _apiService.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      _token = response.data['access_token'];
      _user = UserModel.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_role', _user!.role);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('/logout');
    } finally {
      _token = null;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_role');
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      try {
        final response = await _apiService.dio.get('/profile');
        _user = UserModel.fromJson(response.data);
      } catch (e) {
        _token = null;
        await prefs.remove('token');
      }
    }
    notifyListeners();
  }
}
