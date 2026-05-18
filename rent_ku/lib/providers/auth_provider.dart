import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final dynamic errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('errors')) {
          String errorMessage = 'Login Gagal:';
          (errorData['errors'] as Map).forEach((key, value) {
            errorMessage += '\n• ${value[0]}';
          });
          throw errorMessage;
        } else if (errorData is Map && errorData.containsKey('message')) {
          throw 'Login Gagal: ${errorData['message']}';
        }
      }
      rethrow;
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final Map<String, dynamic> errors = e.response?.data['errors'] ?? {};
        String errorMessage = 'Registrasi Gagal:';
        errors.forEach((key, value) {
          errorMessage += '\n• ${value[0]}';
        });
        throw errorMessage;
      }
      rethrow;
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

  Future<void> updateProfile({String? name, File? photo}) async {
    try {
      FormData formData = FormData();
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (photo != null) {
        formData.files.add(MapEntry(
          'profile_photo',
          await MultipartFile.fromFile(photo.path),
        ));
      }

      final response = await _apiService.dio.post('/profile/update', data: formData);
      _user = UserModel.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      rethrow;
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
