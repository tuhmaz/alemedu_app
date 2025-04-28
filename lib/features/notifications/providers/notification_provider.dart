import 'package:flutter/material.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;

  NotificationProvider(this._apiService);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications = [];
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final response = await _apiService.get(
        '/dashboard/notifications',
        queryParameters: {'page': _currentPage},
        
      );



      if (response != null && response['data'] != null) {
        final List<NotificationModel> newNotifications = (response['data'] as List)
            .map((item) => NotificationModel.fromJson(item))
            .toList();


        _notifications.addAll(newNotifications);
        
        // Update pagination info
        _hasMore = response['current_page'] < response['last_page'];
        if (_hasMore) {
          _currentPage++;
        }

        
        _error = null;
      } else {

        _error = 'لا توجد إشعارات';
      }
    } catch (e) {


      _error = 'فشل في تحميل الإشعارات: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {

      await _apiService.delete(
        '/dashboard/notifications/$notificationId',
      );
      
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      

      return true;
    } catch (e) {

      _error = 'فشل في حذف الإشعار';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {

      await _apiService.patch(
        '/dashboard/notifications/$notificationId/mark-as-read',
        {},
      );
      
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        final updatedNotification = NotificationModel(
          id: notification.id,
          type: notification.type,
          notifiableType: notification.notifiableType,
          notifiableId: notification.notifiableId,
          data: notification.data,
          readAt: DateTime.now(),
          createdAt: notification.createdAt,
          updatedAt: DateTime.now(),
        );
        _notifications[index] = updatedNotification;
        notifyListeners();
      }
      

      return true;
    } catch (e) {

      _error = 'فشل في تحديث حالة الإشعار';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {

      await _apiService.post('/dashboard/notifications/read-all', {});
      
      // Update all local notifications
      final now = DateTime.now();
      _notifications = _notifications.map((notification) => NotificationModel(
        id: notification.id,
        type: notification.type,
        notifiableType: notification.notifiableType,
        notifiableId: notification.notifiableId,
        data: notification.data,
        readAt: now,
        createdAt: notification.createdAt,
        updatedAt: now,
      )).toList();
      
      notifyListeners();

      return true;
    } catch (e) {

      _error = 'فشل في تحديث حالة الإشعارات';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {

      await _apiService.post('/dashboard/notifications/delete-all', {});
      
      _notifications.clear();
      notifyListeners();
      

      return true;
    } catch (e) {

      _error = 'فشل في حذف الإشعارات';
      notifyListeners();
      return false;
    }
  }

  Future<bool> handleBulkActions(List<String> notificationIds, String action) async {
    try {

      await _apiService.post('/dashboard/notifications/handle-actions', {
        'notification_ids': notificationIds,
        'action': action,
      });
      
      if (action == 'delete') {
        _notifications.removeWhere((n) => notificationIds.contains(n.id));
      } else if (action == 'mark_as_read') {
        final now = DateTime.now();
        for (final id in notificationIds) {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            final notification = _notifications[index];
            _notifications[index] = NotificationModel(
              id: notification.id,
              type: notification.type,
              notifiableType: notification.notifiableType,
              notifiableId: notification.notifiableId,
              data: notification.data,
              readAt: now,
              createdAt: notification.createdAt,
              updatedAt: now,
            );
          }
        }
      }
      
      notifyListeners();

      return true;
    } catch (e) {

      _error = 'فشل في تنفيذ العملية';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
