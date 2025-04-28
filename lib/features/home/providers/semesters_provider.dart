import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/semester_model.dart';

class SemestersProvider with ChangeNotifier {
  final _apiService = ApiService();
  List<SemesterModel> _semesters = [];
  bool _isLoading = false;
  String? _error;
  String _selectedDatabase = 'jo';

  List<SemesterModel> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDatabase => _selectedDatabase;

  void updateSelectedDatabase(String database) {
    if (_selectedDatabase != database) {
      _selectedDatabase = database;
      _semesters = []; // إعادة تعيين الفصول عند تغيير قاعدة البيانات
      _error = null;
      notifyListeners();
    }
  }

  Future<void> fetchSemesters(int subjectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '/$_selectedDatabase/lesson/subjects/$subjectId';
      
      final response = await _apiService.get(url);

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['semesters'] != null) {
        final List<dynamic> semestersData = response['data']['semesters'];
        _semesters = semestersData.map((semester) => SemesterModel.fromJson(semester)).toList();
        
        if (_semesters.isEmpty) {
          _error = 'لا توجد فصول دراسية متاحة';
        } else {
          _error = null;
        }
      } else {
        _error = 'لا توجد فصول دراسية متاحة';
      }
    } catch (e) {
      _error = 'حدث خطأ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
