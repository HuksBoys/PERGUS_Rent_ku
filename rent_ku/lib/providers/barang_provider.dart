import 'package:flutter/material.dart';
import '../models/barang_model.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class BarangProvider with ChangeNotifier {
  List<BarangModel> _items = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<BarangModel> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/barang');
      _items = (response.data as List).map((i) => BarangModel.fromJson(i)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      final file = data.remove('gambar_file');
      FormData formData = FormData.fromMap(data);
      if (file != null) {
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          'gambar',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      final response = await _apiService.dio.post('/barang', data: formData);
      debugPrint('Upload success: ${response.data}');
      await fetchItems();
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> data) async {
    try {
      final file = data.remove('gambar_file');
      FormData formData = FormData.fromMap({
        ...data,
        '_method': 'PUT',
      });
      
      if (file != null) {
        formData.files.add(MapEntry(
          'gambar',
          await MultipartFile.fromFile(file.path),
        ));
      }

      await _apiService.dio.post('/barang/$id', data: formData);
      await fetchItems();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _apiService.dio.delete('/barang/$id');
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
