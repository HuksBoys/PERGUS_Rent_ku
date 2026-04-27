import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class TransaksiProvider with ChangeNotifier {
  List<TransaksiModel> _transaksi = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<TransaksiModel> get transaksi => _transaksi;
  bool get isLoading => _isLoading;

  Future<void> fetchTransaksi() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/transaksi');
      _transaksi = (response.data as List).map((i) => TransaksiModel.fromJson(i)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTransaksi(Map<String, dynamic> data) async {
    try {
      await _apiService.dio.post('/transaksi', data: data);
      await fetchTransaksi();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await _apiService.dio.put('/transaksi/$id', data: {'status': status});
      await fetchTransaksi();
    } catch (e) {
      rethrow;
    }
  }
}
