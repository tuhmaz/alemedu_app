import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../../../core/services/api_service.dart';
import '../../../core/models/news_model.dart';
import '../services/news_comment_service.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService;
  final NewsCommentService _commentService;
  List<NewsModel> _news = [];
  final List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedDatabase = '';
  String? _selectedCategory;
  Map<String, IconData> _categoryIcons = {};
  Map<String, Color> _categoryColors = {};
  List<String>? _cachedUniqueCategories;
  final Map<String, List<NewsModel>> _cachedGroupedNews = {};
  final Map<String, int> _newsCountCache = {};

  NewsProvider(this._apiService, this._commentService) {
    _initializeCategoryData();
  }
  
  void _initializeCategoryData() {
    _categoryIcons = {
      'أكاديمي': Icons.school, 'رياضي': Icons.sports_soccer, 'ثقافي': Icons.theater_comedy, 'فني': Icons.palette, 'اجتماعي': Icons.people, 'تقني': Icons.computer, 'علمي': Icons.science, 'ديني': Icons.mosque,
    };
    _categoryColors = {
      'أكاديمي': Color(0xFF1565C0), 'رياضي': Color(0xFF2E7D32), 'ثقافي': Color(0xFF6A1B9A), 'فني': Color(0xFFE65100), 'اجتماعي': Color(0xFF00838F), 'تقني': Color(0xFF283593), 'علمي': Color(0xFF00695C), 'ديني': Color(0xFF4E342E),
    };
  }

  List<NewsModel> get news => UnmodifiableListView(_news);
  
  
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedDatabase => _selectedDatabase;
  String? get selectedCategory => _selectedCategory;
  NewsCommentService get commentService => _commentService;

  // الحصول على قائمة الفئات الفريدة
    List<String> get uniqueCategories {
    if (_cachedUniqueCategories != null) {
      return _cachedUniqueCategories!;
    }
    Set<String> uniqueCategories = {};
      for (var news in _news) {
        if (news.category?.name != null) {
          uniqueCategories.add(news.category!.name);
        }
      }
    return ['الكل', ...uniqueCategories];
  }

  // تحديد قاعدة البيانات
  Future<void> setDatabase(String database) async {
    if (_selectedDatabase != database) {
      _selectedDatabase = database;
      _selectedCategory = null;
      _news = []; // مسح الأخبار القديمة
      _error = '';
      
      // تحديث قاعدة البيانات في خدمة التعليقات
      _commentService.updateSelectedDatabase(database);
      
      notifyListeners();
       _cachedUniqueCategories = null;
      _cachedGroupedNews.clear();
      _newsCountCache.clear();
      // جلب الأخبار الجديدة
      await fetchNews(refresh: true);
    }
  }

  // تحديد الفئة المختارة
  void selectCategory(String category) {
    _selectedCategory = category == 'الكل' ? null : category;
    notifyListeners();
  }

  // الحصول على الأخبار المصنفة حسب الفئة المحددة
  List<NewsModel> getGroupedNews() {
  if (_selectedCategory == null) {
    return UnmodifiableListView(_news);
  }
  if (_cachedGroupedNews.containsKey(_selectedCategory)) {
    return UnmodifiableListView(_cachedGroupedNews[_selectedCategory]!);
  }
  List<NewsModel> groupedNews = _news.where((news) => news.category?.name == _selectedCategory).toList();
  _cachedGroupedNews[_selectedCategory!] = groupedNews;
  return UnmodifiableListView(groupedNews);
}


  // جلب الأخبار
  Future<void> fetchNews({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = '';
    if (refresh) {
       _cachedUniqueCategories = null;
      _cachedGroupedNews.clear();
      _news = [];
      _newsCountCache.clear();
    }
    notifyListeners();

    try {
      if (_selectedDatabase.isEmpty) {
        _error = 'الرجاء اختيار قاعدة بيانات';
        _isLoading = false;
        notifyListeners();
                return;
      }

      final response = await _apiService.get('/$_selectedDatabase/news');
      
      if (response != null && response['status'] == true) {
           final List<dynamic> newsItems = response['data']['items'] as List<dynamic>;
        if (newsItems.isNotEmpty) {
          List<NewsModel> newNews = await compute(_processNewsItems, newsItems);
           if (refresh) {
            _news = newNews;
          } else {
            _news.addAll(newNews);
          }
          _error = '';
        } else {
          _error = 'حدث خطأ في جلب الأخبار';
           _news = [];
        }
      }
    } catch (e) {
      _error = 'حدث خطأ في جلب الأخبار: $e';
      _news = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 static Future<List<NewsModel>> _processNewsItems(List<dynamic> newsItems) async {
    return newsItems.map((item) {
      if (item['image'] != null) {
        item['image'] = _transformImageUrl(item['image']);
      }
      item['description'] = item['content'];
      return NewsModel.fromJson(item);
    }).toList();
  }
  // تحديث الأخبار
  void refreshNews() {
    _selectedCategory = null;
    fetchNews(refresh: true);
  }

  static String _transformImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
        return '';
    }
    String cleanUrl = imageUrl.replaceAll(RegExp(r'\.webp$', caseSensitive: false), '');

    if (!cleanUrl.startsWith('http')) {
        cleanUrl = cleanUrl.startsWith('/') ? cleanUrl.substring(1) : cleanUrl;
        cleanUrl = 'https://alemedu.com/storage/$cleanUrl.webp';
    }
    
    // إضافة البروتوكول إذا لم يكن موجوداً
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = cleanUrl.startsWith('/')
          ? cleanUrl.substring(1)
          : cleanUrl;
    cleanUrl = 'https://alemedu.com/storage/$cleanUrl.webp';
  }
    return cleanUrl;
  }

  IconData getCategoryIcon(String category) {
    String normalizedCategory = category.toLowerCase();
    String key = _categoryIcons.keys.firstWhere((k) => k.toLowerCase() == normalizedCategory, orElse: () => 'أخرى');
    return _categoryIcons[key] ?? Icons.article;
  }

  Color getCategoryColor(String category) {
    String normalizedCategory = category.toLowerCase();
    String key = _categoryColors.keys.firstWhere((k) => k.toLowerCase() == normalizedCategory, orElse: () => 'أخرى');
    return _categoryColors[key] ?? Color(0xFF546E7A);
  }

 int getNewsCountForCategory(String category) {
    if (!_newsCountCache.containsKey(category)) {
      _newsCountCache[category] = category == 'الكل' ? _news.length : _news.where((news) => news.category?.name == category).length;
    }
    return _newsCountCache[category]!;
  }
}
