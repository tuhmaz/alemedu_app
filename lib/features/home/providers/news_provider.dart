import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/news_model.dart';
import '../services/news_comment_service.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService;
  final NewsCommentService _commentService;
  List<NewsModel> _news = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';
  String _selectedDatabase = '';
  String? _selectedCategory;

  NewsProvider(this._apiService, this._commentService);

  List<NewsModel> get news => _news;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedDatabase => _selectedDatabase;
  String? get selectedCategory => _selectedCategory;
  NewsCommentService get commentService => _commentService;

  // الحصول على قائمة الفئات الفريدة
  List<String> get uniqueCategories {
    final Set<String> uniqueCategories = {};
    for (var news in _news) {
      if (news.category?.name != null) {
        uniqueCategories.add(news.category!.name);
      }
    }
    return ['الكل', ...uniqueCategories.toList()];
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
      return _news;
    }
    return _news.where((news) => news.category?.name == _selectedCategory).toList();
  }

  // جلب الأخبار
  Future<void> fetchNews({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = '';
    if (refresh) {
      _news = [];
    }
    notifyListeners();

    try {
      if (_selectedDatabase.isEmpty) {
        _error = 'الرجاء اختيار قاعدة بيانات';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Fetching news for database: $_selectedDatabase');
      final response = await _apiService.get('/$_selectedDatabase/news');
      print('API Response: $response');
      
      if (response != null && response['status'] == true) {
        final List<dynamic> newsItems = response['data']['items'] as List<dynamic>;
        print('Number of news items: ${newsItems.length}');
        
        _news = newsItems.map((item) {
          print('Processing news item: ${item['title']}');
          if (item['image'] != null) {
            item['image'] = _transformImageUrl(item['image']);
            print('Transformed image URL: ${item['image']}');
          }
          
          // Map content to description for compatibility
          item['description'] = item['content'];
          
          return NewsModel.fromJson(item);
        }).toList();
        
        print('Processed news items: ${_news.length}');
        print('Sample image URLs:');
        for (var news in _news.take(3)) {
          print('- ${news.title}: ${news.image}');
        }
        
        _error = '';
      } else {
        _error = 'حدث خطأ في جلب الأخبار';
        _news = [];
        print('Error: Empty response from API');
      }
    } catch (e) {
      _error = 'حدث خطأ في جلب الأخبار: $e';
      _news = [];
      print('Error fetching news: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث الأخبار
  void refreshNews() {
    _selectedCategory = null;
    fetchNews(refresh: true);
  }

  // Transform image URL
  String _transformImageUrl(String? imageUrl) {
    print('Transforming image URL: $imageUrl');
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // تنظيف الرابط من أي .webp في النهاية
    String cleanUrl = imageUrl;
    while (cleanUrl.toLowerCase().endsWith('.webp')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 5);
    }
    
    // إضافة البروتوكول إذا لم يكن موجوداً
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = cleanUrl.startsWith('/')
          ? cleanUrl.substring(1)
          : cleanUrl;
      cleanUrl = 'https://alemedu.com/storage/images/$cleanUrl.webp';
    }
    
    print('Final image URL: $cleanUrl');
    return cleanUrl;
  }

  // الحصول على أيقونة مناسبة لكل فئة
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'أكاديمي':
      case 'academic':
        return Icons.school;
      case 'رياضي':
      case 'sports':
        return Icons.sports_soccer;
      case 'ثقافي':
      case 'cultural':
        return Icons.theater_comedy;
      case 'فني':
      case 'art':
        return Icons.palette;
      case 'اجتماعي':
      case 'social':
        return Icons.people;
      case 'تقني':
      case 'technology':
        return Icons.computer;
      case 'علمي':
      case 'science':
        return Icons.science;
      case 'ديني':
      case 'religious':
        return Icons.mosque;
      default:
        return Icons.article;
    }
  }

  // الحصول على لون مناسب لكل فئة
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'أكاديمي':
      case 'academic':
        return Color(0xFF1565C0); // أزرق غامق
      case 'رياضي':
      case 'sports':
        return Color(0xFF2E7D32); // أخضر غامق
      case 'ثقافي':
      case 'cultural':
        return Color(0xFF6A1B9A); // بنفسجي
      case 'فني':
      case 'art':
        return Color(0xFFE65100); // برتقالي غامق
      case 'اجتماعي':
      case 'social':
        return Color(0xFF00838F); // تركواز غامق
      case 'تقني':
      case 'technology':
        return Color(0xFF283593); // نيلي
      case 'علمي':
      case 'science':
        return Color(0xFF00695C); // أخضر مزرق غامق
      case 'ديني':
      case 'religious':
        return Color(0xFF4E342E); // بني
      default:
        return Color(0xFF546E7A); // رمادي مزرق
    }
  }

  // الحصول على عدد الأخبار في كل فئة
  int getNewsCountForCategory(String category) {
    if (category == 'الكل') {
      return _news.length;
    }
    return _news.where((news) => news.category?.name == category).length;
  }
}
