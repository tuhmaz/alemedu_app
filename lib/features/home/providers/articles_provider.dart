import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/article_model.dart';

class ArticlesProvider with ChangeNotifier {
  final _apiService = ApiService();
  List<ArticleModel> _articles = [];
  ArticleModel? _selectedArticle;
  bool _isLoading = false;
  String? _error;
  String _selectedDatabase = 'jo';
  Map<String, dynamic>? _selectedSubject;

  List<ArticleModel> get articles => _articles;
  ArticleModel? get selectedArticle => _selectedArticle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDatabase => _selectedDatabase;
  Map<String, dynamic>? get selectedSubject => _selectedSubject;

  void updateSelectedDatabase(String database) {
    if (_selectedDatabase != database) {
      _selectedDatabase = database;
      _articles = []; // إعادة تعيين المقالات عند تغيير قاعدة البيانات
      _selectedArticle = null;
      _error = null;
      Future.microtask(() => notifyListeners());
    }
  }

  void setSelectedSubject(Map<String, dynamic> subject) {
    _selectedSubject = subject;
    Future.microtask(() => notifyListeners());
  }

  Future<void> fetchArticles({
    required int subjectId,
    required int semesterId,
    required String category,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final url = '/$_selectedDatabase/lesson/subjects/$subjectId/articles/$semesterId/$category';
      
      final response = await _apiService.get(url);

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['articles'] != null) {
        final List<dynamic> articlesData = response['data']['articles'];
        
        _articles = articlesData.map((json) {
          final article = ArticleModel.fromJson(json);
          return article;
        }).toList();
        
        if (_articles.isEmpty) {
          _error = 'لا توجد مقالات متاحة';
        } else {
          _error = null;
        }
      } else {
        _articles = [];
        _error = 'لا توجد مقالات متاحة';
      }
    } catch (e) {
      _error = 'حدث خطأ: $e';
      _articles = [];
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }

  Future<void> fetchArticleDetails(int articleId) async {
    if (_isLoading || (_selectedArticle?.id == articleId)) {
      return;
    }

    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final url = '/$_selectedDatabase/lesson/articles/$articleId';
      final response = await _apiService.get(url);

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['item'] != null) {
          _selectedArticle = ArticleModel.fromJson(response['data']['item']);
        _error = null;
      } else {
        _selectedArticle = null;
        _error = 'لا يمكن تحميل تفاصيل المقالة';
      }
    } catch (e) {
      _selectedArticle = null;
      _error = 'حدث خطأ أثناء تحميل تفاصيل المقالة';
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }
}
