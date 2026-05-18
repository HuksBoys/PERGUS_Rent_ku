import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<MessageModel> _messages = [];
  List<UserModel> _chatList = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<MessageModel> get messages => _messages;
  List<UserModel> get chatList => _chatList;
  bool get isLoading => _isLoading;

  Future<void> fetchMessages(int otherUserId) async {
    try {
      final response = await _apiService.dio.get('/messages/$otherUserId');
      _messages = (response.data as List).map((i) => MessageModel.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(int receiverId, String message) async {
    try {
      final response = await _apiService.dio.post('/messages', data: {
        'receiver_id': receiverId,
        'message': message,
      });
      _messages.add(MessageModel.fromJson(response.data));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchChatList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/messages/list');
      _chatList = (response.data as List).map((i) => UserModel.fromJson(i)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> getAdminId() async {
    try {
      final response = await _apiService.dio.get('/messages/admin');
      return response.data['admin_id'];
    } catch (e) {
      return null;
    }
  }
}
