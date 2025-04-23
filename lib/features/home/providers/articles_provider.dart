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
    print('تحديث قاعدة البيانات المحددة من $_selectedDatabase إلى $database');
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

    print('=== بدء جلب المقالات ===');
    print('قاعدة البيانات المحددة: $_selectedDatabase');
    print('Subject ID: $subjectId, Semester ID: $semesterId, Category: $category');
    
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final url = '/$_selectedDatabase/lesson/subjects/$subjectId/articles/$semesterId/$category';
      print('Requesting URL: $url');
      
      final response = await _apiService.get(url);
      print('API Response: $response');

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['articles'] != null) {
        print('Found articles in response');
        final List<dynamic> articlesData = response['data']['articles'];
        print('Articles data count: ${articlesData.length}');
        
        _articles = articlesData.map((json) {
          final article = ArticleModel.fromJson(json);
          print('Processed article: $article');
          return article;
        }).toList();
        
        if (_articles.isEmpty) {
          _error = 'لا توجد مقالات متاحة';
        } else {
          _error = null;
        }
        print('Total processed articles: ${_articles.length}');
      } else {
        print('No articles found in response');
        _articles = [];
        _error = 'لا توجد مقالات متاحة';
      }
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
      _error = 'حدث خطأ: $e';
      _articles = [];
    }

    _isLoading = false;
    print('Final articles count: ${_articles.length}');
    print('Final error state: $_error');
    print('=== نهاية جلب المقالات ===');
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
      print('Requesting article details URL: $url');
      final response = await _apiService.get(url);
      print('Article details response: $response');

      if (response != null && 
          response['status'] == true && 
          response['data'] != null &&
          response['data']['status'] == true &&
          response['data']['item'] != null) {
        _selectedArticle = ArticleModel.fromJson(response['data']['item']);
        _error = null;
        print('Successfully loaded article: ${_selectedArticle?.title}');
      } else {
        print('Invalid article details response structure');
        _selectedArticle = null;
        _error = 'لا يمكن تحميل تفاصيل المقالة';
      }
    } catch (e) {
      print('Error fetching article details: $e');
      _selectedArticle = null;
      _error = 'حدث خطأ أثناء تحميل تفاصيل المقالة';
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }
}
