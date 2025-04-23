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
    print('تحديث قاعدة البيانات المحددة من $_selectedDatabase إلى $database');
    if (_selectedDatabase != database) {
      _selectedDatabase = database;
      _semesters = []; // إعادة تعيين الفصول عند تغيير قاعدة البيانات
      _error = null;
      notifyListeners();
    }
  }

  Future<void> fetchSemesters(int subjectId) async {
    print('=== بدء جلب الفصول الدراسية ===');
    print('قاعدة البيانات المحددة: $_selectedDatabase');
    print('Subject ID: $subjectId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '/$_selectedDatabase/lesson/subjects/$subjectId';
      print('Requesting URL: $url');
      
      final response = await _apiService.get(url);
      print('API Response: $response');

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['semesters'] != null) {
        print('Found semesters in response');
        final List<dynamic> semestersData = response['data']['semesters'];
        _semesters = semestersData.map((semester) => SemesterModel.fromJson(semester)).toList();
        
        print('Processed semesters: $_semesters');
        if (_semesters.isEmpty) {
          _error = 'لا توجد فصول دراسية متاحة';
        } else {
          _error = null;
        }
      } else {
        print('No semesters found in response');
        _error = 'لا توجد فصول دراسية متاحة';
      }
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      _error = 'حدث خطأ: $e';
    } finally {
      _isLoading = false;
      print('Final semesters list: $_semesters');
      print('Final error state: $_error');
      print('=== نهاية جلب الفصول الدراسية ===');
      notifyListeners();
    }
  }
}
