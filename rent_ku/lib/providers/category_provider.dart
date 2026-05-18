import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/categories');
      _categories = (response.data as List).map((i) => CategoryModel.fromJson(i)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryModel> addCategory(String name) async {
    try {
      final response = await _apiService.dio.post('/categories', data: {'name': name});
      final newCategory = CategoryModel.fromJson(response.data);
      _categories.add(newCategory);
      notifyListeners();
      return newCategory;
    } catch (e) {
      rethrow;
    }
  }
}
