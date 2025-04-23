import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';
import '../../../core/services/api_service.dart';

class MessageProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<MessageModel> _messages = [];
  List<MessageModel> _sentMessages = [];
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingUsers = false;

  MessageProvider(this._apiService);

  List<MessageModel> get messages => _messages;
  List<MessageModel> get sentMessages => _sentMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get allUsers => _allUsers;
  bool get isLoadingUsers => _isLoadingUsers;

  int get unreadCount => _messages.where((message) => !message.read).length;

  bool get hasUnreadMessages => unreadCount > 0;

  Future<void> fetchMessages() async {
    try {

      _isLoading = true;
      _error = null;
      notifyListeners();
      print('🔄 جاري الاتصال بالخادم...');

      final response = await _apiService.get('/dashboard/messages');
      print('📥 استجابة الخادم: $response');

      if (response != null && response['messages'] != null) {

        _messages = (response['messages'] as List)
            .map((message) => MessageModel.fromJson(message))
            .toList();


      } else {

      }
    } catch (e) {

      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();

    }
  }

  Future<void> fetchSentMessages() async {
    try {

      _isLoading = true;
      _error = null;
      notifyListeners();
      print('🔄 جاري الاتصال بالخادم...');

      final response = await _apiService.get('/dashboard/messages/sent');
      print('📥 استجابة الخادم: $response');

      if (response != null && response['sent_messages'] != null) {

        _sentMessages = (response['sent_messages'] as List)
            .map((message) => MessageModel.fromJson(message))
            .toList();


      } else {

        _sentMessages = [];
      }
    } catch (e) {

      _error = e.toString();
      _sentMessages = [];
    } finally {
      _isLoading = false;
      notifyListeners();

    }
  }

  Future<void> fetchAllUsers() async {
    if (_isLoadingUsers) return; // Prevent multiple simultaneous calls
    
    try {

      _isLoadingUsers = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/dashboard/users');


      if (response != null && (response['data'] != null || response['users'] != null)) {
        final users = response['data'] ?? response['users'];
        _allUsers = List<Map<String, dynamic>>.from(users);

      } else {

        _allUsers = [];
      }
    } catch (e) {

      _error = e.toString();
      _allUsers = [];
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> composeMessage() async {
    try {
      print('📝 جاري تحضير نموذج الرسالة الجديدة');
      final response = await _apiService.get('/dashboard/messages/compose');
      print('📥 استجابة تحضير الرسالة: $response');
      
      if (response != null) {
        return response;
      }
      return null;
    } catch (e) {
      print('❌ خطأ في تحضير الرسالة: $e');
      _error = e.toString();
      return null;
    }
  }

  Future<MessageModel?> sendMessage({
    required int recipientId,
    required String subject,
    required String body,
  }) async {
    try {
      print('📧 بدء إرسال رسالة جديدة');
      print('👤 المستلم: $recipientId');
      print('📌 الموضوع: $subject');
      print('📝 المحتوى: $body');
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/dashboard/messages/send', {
        'recipient_id': recipientId,
        'subject': subject,
        'body': body,
      });
      print('📥 استجابة إرسال الرسالة: $response');

      if (response != null && response['message_details'] != null) {
        print('✅ تم إرسال الرسالة بنجاح');
        final messageData = response['message_details'];
        final newMessage = MessageModel.fromJson(messageData);
        _sentMessages.insert(0, newMessage);
        notifyListeners();
        
        // Show success message
        _error = null;
        return newMessage;
      } else {
        print('⚠️ لم يتم استلام تفاصيل الرسالة من الخادم');
        print('⚠️ محتوى الاستجابة: $response');
        _error = 'فشل في إرسال الرسالة';
      }
      return null;
    } catch (e) {
      print('❌ خطأ في إرسال الرسالة: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 اكتملت عملية إرسال الرسالة');
    }
  }

  Future<MessageModel?> replyToMessage({
    required int messageId,
    required String body,
  }) async {
    try {
      print('📧 بدء الرد على رسالة');
      print('📨 الرسالة الأصلية: $messageId');
      print('📝 المحتوى: $body');
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/dashboard/messages/$messageId/reply', {
        'body': body,
      });
      print('📥 استجابة الخادم: $response');

      if (response != null && response['reply'] != null) {
        print('✅ تم الرد على الرسالة بنجاح');
        final replyMessage = MessageModel.fromJson(response['reply']);
        _sentMessages.insert(0, replyMessage);
        notifyListeners();
        return replyMessage;
      } else {
        print('⚠️ لم يتم استلام تفاصيل الرد من الخادم');
      }
      return null;
    } catch (e) {
      print('❌ خطأ في الرد على الرسالة: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 اكتملت عملية الرد على الرسالة');
    }
  }

  Future<bool> markAsRead(int messageId) async {
    try {
      print('📨 بدء وضع علامة القراءة على رسالة');
      print('📨 الرسالة: $messageId');
      
      final response = await _apiService.post('/dashboard/messages/$messageId/mark-as-read', {});
      print('📥 استجابة الخادم: $response');

      if (response != null) {
        print('✅ تم وضع علامة القراءة على الرسالة بنجاح');
        final messageIndex = _messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = MessageModel.fromJson({
            ..._messages[messageIndex].toJson(),
            'read': true,
          });
          _messages[messageIndex] = updatedMessage;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ خطأ في وضع علامة القراءة على الرسالة: $e');
      _error = e.toString();
      return false;
    }
  }

  Future<bool> toggleImportant(int messageId) async {
    try {
      print('📨 بدء تغيير وضع الاهمية للرسالة');
      print('📨 الرسالة: $messageId');
      
      final response = await _apiService.post('/dashboard/messages/$messageId/toggle-important', {});
      print('📥 استجابة الخادم: $response');

      if (response != null && response['important_status'] != null) {
        print('✅ تم تغيير وضع الاهمية للرسالة بنجاح');
        final messageIndex = _messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = MessageModel.fromJson({
            ..._messages[messageIndex].toJson(),
            'is_important': response['important_status'],
          });
          _messages[messageIndex] = updatedMessage;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ خطأ في تغيير وضع الاهمية للرسالة: $e');
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      print('📨 بدء حذف رسالة');
      print('📨 الرسالة: $messageId');
      
      final response = await _apiService.delete('/dashboard/messages/$messageId');
      print('📥 استجابة الخادم: $response');

      if (response != null) {
        print('✅ تم حذف الرسالة بنجاح');
        _messages.removeWhere((m) => m.id == messageId);
        _sentMessages.removeWhere((m) => m.id == messageId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ خطأ في حذف الرسالة: $e');
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteSelectedMessages(List<int> messageIds) async {
    try {
      print('📨 بدء حذف رسائل متعددة');
      print('📨 الرسائل: $messageIds');
      
      final response = await _apiService.post('/dashboard/messages/delete-selected', {
        'selected_messages': messageIds,
      });
      print('📥 استجابة الخادم: $response');

      if (response != null) {
        print('✅ تم حذف الرسائل بنجاح');
        _messages.removeWhere((m) => messageIds.contains(m.id));
        _sentMessages.removeWhere((m) => messageIds.contains(m.id));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ خطأ في حذف الرسائل: $e');
      _error = e.toString();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('🔍 البحث عن المستخدمين: $query');
      print('🌐 Making GET request to: /dashboard/users/search?query=$query');
      
      final response = await _apiService.get('/dashboard/users/search', queryParameters: {'query': query});
      print('📥 Response: $response');
      
      if (response != null && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else if (response != null && response['users'] != null) {
        return List<Map<String, dynamic>>.from(response['users']);
      } else {
        print('⚠️ No users found in response: $response');
        return [];
      }
    } catch (e) {
      print('❌ Error searching users: $e');
      _error = e.toString();
      return [];
    }
  }

  Future<bool> markMessageAsRead(int messageId) async {
    try {
      final response = await _apiService.post(
        '/dashboard/messages/$messageId/mark-as-read',
        {},
      );

      if (response.statusCode == 200) {
        final messageIndex = _messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = MessageModel.fromJson(response.data['data']);
          _messages[messageIndex] = updatedMessage;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }
}
