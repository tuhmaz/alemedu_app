import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../../../core/services/api_service.dart';

class SubjectsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<SubjectModel> _subjects = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedDatabase = 'jo';

  List<SubjectModel> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedDatabase => _selectedDatabase;

  void updateSelectedDatabase(String database) {

    if (_selectedDatabase != database) {
      _selectedDatabase = database;
      _subjects = []; // إعادة تعيين المواد عند تغيير قاعدة البيانات
      _error = '';
      notifyListeners();
    }
  }

  Future<void> fetchSubjects(int gradeId) async {

    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = '/$_selectedDatabase/lesson/$gradeId';

      
      final response = await _apiService.get(url);


      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['subjects'] != null) {
        final List<dynamic> subjectsData = response['data']['subjects'];
        
        final List<SubjectModel> loadedSubjects = [];
        for (var subject in subjectsData) {

          try {
            loadedSubjects.add(SubjectModel.fromJson(subject));
          } catch (e) {

          }
        }
        
        _subjects = loadedSubjects;

        if (_subjects.isEmpty) {
          _error = 'لم يتم العثور على أي مواد دراسية';
        } else {
          _error = '';
        }
      } else {
        _error = 'لا توجد مواد دراسية متاحة لهذا الصف';
      }
    } catch (e) {
      _error = 'حدث خطأ في الاتصال: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
