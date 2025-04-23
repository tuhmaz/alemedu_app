import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/class_model.dart';

class ClassesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String _error = '';

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchClasses(String database) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await _apiService.get('/$database/lesson');
      print('Lesson response: $response');
      
      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['grades'] != null) {
        final List<dynamic> gradesData = response['data']['grades'];
        _classes = gradesData.map((json) => ClassModel.fromJson(json)).toList();
        print('Loaded ${_classes.length} classes');
        if (_classes.isEmpty) {
          _error = 'لا توجد صفوف متاحة';
        }
      } else {
        print('Invalid response structure or no grades found');
        _error = 'لا توجد صفوف متاحة';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل الصفوف';
      print('Error fetching classes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
