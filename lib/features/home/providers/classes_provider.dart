import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/class_model.dart';

class ClassesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
   ClassesProvider();
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String _error = '';

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String get error => _error;


  Future<void> fetchClasses(String database) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
       final response = await _apiService.get('/$database/lesson');
       if (response != null &&
           response['status'] == true &&
           response['data'] != null &&
           response['data']['status'] == true &&
           response['data']['grades'] != null) {
         final List<dynamic> gradesData =
             response['data']['grades'] as List<dynamic>;
         _classes =
             gradesData.map((json) => ClassModel.fromJson(json)).toList();
         if (_classes.isEmpty) {
           _error = 'لا توجد صفوف متاحة';
         }
        }else {
        _error = 'لا توجد صفوف متاحة';
        }
       
    } on Exception {
      _error = 'حدث خطأ أثناء تحميل الصفوف';
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}
