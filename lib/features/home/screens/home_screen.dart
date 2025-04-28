import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/classes_provider.dart';
import '../providers/articles_provider.dart';
import '../providers/subjects_provider.dart';
import '../providers/semesters_provider.dart';
import '../providers/news_provider.dart';
import '../../../core/models/news_model.dart';  // تصحيح المسار
import 'subjects_screen.dart';
import 'news_details_screen.dart';
import 'package:extended_image/extended_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // TODO: Add _bannerAd
  late BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  // TODO: Add _loadBannerAd()
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _isBannerAdReady = false;
          });
          // Dispose the ad here to free resources.
          ad.dispose();
          // print('Failed to load a banner ad: ${err.message}');
        },
      ),
    )..load();
  }

  String _selectedDatabase = 'jo';
  final _random = math.Random();

  final Map<String, String> _countries = {
    'jo': 'الأردن',
    'sa': 'السعودية',
    'eg': 'مصر',
    'ps': 'فلسطين',
  };

  // قائمة من الألوان الجميلة للأزرار
  final List<List<Color>> _buttonColors = [
    [const Color(0xFF4CAF50), const Color(0xFF388E3C)], // أخضر
    [const Color(0xFF2196F3), const Color(0xFF1976D2)], // أزرق
    [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)], // بنفسجي
    [const Color(0xFFE91E63), const Color(0xFFC2185B)], // وردي
    [const Color(0xFFFF9800), const Color(0xFFF57C00)], // برتقالي
  ];

  // دالة للحصول على أيقونة مناسبة للصف
  IconData _getGradeIcon(String title) {
    if (title.contains('الأول')) {
      return Icons.looks_one;
    } else if (title.contains('الثاني')) {
      return Icons.looks_two;
    } else if (title.contains('الثالث')) {
      return Icons.looks_3;
    } else if (title.contains('الرابع')) {
      return Icons.looks_4;
    } else if (title.contains('الخامس')) {
      return Icons.looks_5;
    } else if (title.contains('السادس')) {
      return Icons.looks_6;
    } else if (title.contains('السابع')) {
      return Icons.filter_7;
    } else if (title.contains('الثامن')) {
      return Icons.filter_8;
    } else if (title.contains('التاسع')) {
      return Icons.filter_9;
    } else if (title.contains('العاشر')) {
      return Icons.filter_9_plus;
    } else if (title.contains('الحادي عشر')) {
      return Icons.school;
    } else if (title.contains('الثاني عشر')) {
      return Icons.school;
    }
    return Icons.class_;
  }

  // دالة للحصول على أيقونة الخلفية المناسبة للصف
  IconData _getBackgroundIcon(String title) {
    if (title.contains('الأول')) {
      return Icons.auto_stories;
    } else if (title.contains('الثاني')) {
      return Icons.menu_book;
    } else if (title.contains('الثالث')) {
      return Icons.library_books;
    } else if (title.contains('الرابع')) {
      return Icons.science;
    } else if (title.contains('الخامس')) {
      return Icons.calculate;
    } else if (title.contains('السادس')) {
      return Icons.psychology;
    } else if (title.contains('السابع')) {
      return Icons.biotech;
    } else if (title.contains('الثامن')) {
      return Icons.functions;
    } else if (title.contains('التاسع')) {
      return Icons.architecture;
    } else if (title.contains('العاشر')) {
      return Icons.engineering;
    } else if (title.contains('الحادي عشر')) {
      return Icons.analytics;
    } else if (title.contains('الثاني عشر')) {
      return Icons.school;
    }
    return Icons.class_;
  }

  List<Color> _getRandomGradientColors() {
    final List<List<Color>> gradients = [
      [Colors.blue[400]!, Colors.blue[600]!],
      [Colors.purple[400]!, Colors.purple[600]!],
      [Colors.green[400]!, Colors.green[600]!],
      [Colors.orange[400]!, Colors.orange[600]!],
      [Colors.pink[400]!, Colors.pink[600]!],
      [Colors.teal[400]!, Colors.teal[600]!],
    ];
    return gradients[math.Random().nextInt(gradients.length)];
  }

  Widget _bannerAdWidget() {
      if (!_isBannerAdReady) {
        return const SizedBox.shrink();
      }
    
      return SizedBox(

      height: 50,
      child: _isBannerAdReady ? AdWidget(ad: _bannerAd) : const SizedBox.shrink(),
    );

  }

  // Get color for grade level
  Color _getColorForGrade(int gradeLevel) {
    final colors = [
      Color(0xFF2196F3),  // أزرق فاتح
      Color(0xFF4CAF50),  // أخضر
      Color(0xFF9C27B0),  // بنفسجي
      Color(0xFF3F51B5),  // نيلي
      Color(0xFFE91E63),  // وردي
      Color(0xFF009688),  // فيروزي
      Color(0xFF673AB7),  // بنفسجي غامق
      Color(0xFFF44336),  // أحمر
      Color(0xFF795548),  // بني
      Color(0xFF607D8B),  // رمادي مزرق
      Color(0xFF00BCD4),  // سماوي
      Color(0xFFFF5722),  // برتقالي محمر
    ];
    
    return colors[(gradeLevel - 1) % colors.length];
  }

  void _handleGradeSelection(int gradeLevel) {
    final classItem = Provider.of<ClassesProvider>(context, listen: false)
        .classes
        .firstWhere((c) => c.gradeLevel == gradeLevel);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectsScreen(
          gradeId: classItem.id,
          gradeName: classItem.gradeName,
        ),
      ),
    );
  }

  Widget _buildGradeButton(int gradeLevel, String gradeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: InkWell(
        onTap: () => _handleGradeSelection(gradeLevel),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _getColorForGrade(gradeLevel).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _getColorForGrade(gradeLevel).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                decoration: BoxDecoration(
                  color: _getColorForGrade(gradeLevel),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getColorForGrade(gradeLevel),
                      _getColorForGrade(gradeLevel).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Icon(
                  _getIconForGrade(gradeLevel),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _getColorForGrade(gradeLevel).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gradeName,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: _getColorForGrade(gradeLevel),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // عرض رسالة التحميل
        if (newsProvider.isLoading && newsProvider.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل الأخبار...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // عرض رسالة الخطأ
        if (newsProvider.error.isNotEmpty && newsProvider.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  newsProvider.error,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => newsProvider.refreshNews(),
                  icon: Icon(Icons.refresh),
                  label: Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // عرض رسالة عند عدم وجود أخبار
        if (newsProvider.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.newspaper, color: Colors.grey[400], size: 48),
                SizedBox(height: 16),
                Text(
                  'لا توجد أخبار متاحة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (newsProvider.selectedDatabase.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'الرجاء اختيار قاعدة بيانات',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
              ],
            ),
          );
        }

        final categories = newsProvider.uniqueCategories.where((cat) => cat != 'الكل').toList();
        
        return Column(
          children: [
            // عنوان القسم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.category, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'أقسام الأخبار',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // شبكة بطاقات الفئات
            GridView.builder(
              padding: EdgeInsets.all(16),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final color = newsProvider.getCategoryColor(category);
                final icon = newsProvider.getCategoryIcon(category);
                
                // عدد الأخبار في هذه الفئة
                final newsCount = newsProvider.news
                    .where((news) => news.category?.name == category)
                    .length;

                return _buildCategoryCard(context, category, newsProvider);
              },
            ),

            // عرض الأخبار المصفاة
            if (newsProvider.selectedCategory != null)
              ..._buildFilteredNews(newsProvider),
          ],
        );
      },
    );
  }

  List<Widget> _buildFilteredNews(NewsProvider newsProvider) {
    final filteredNews = newsProvider.getGroupedNews();
    
    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              newsProvider.getCategoryIcon(newsProvider.selectedCategory!),
              color: newsProvider.getCategoryColor(newsProvider.selectedCategory!),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'أخبار ${newsProvider.selectedCategory}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => newsProvider.selectCategory('الكل'),
              child: Text('عرض الكل'),
            ),
          ],
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: filteredNews.length,
        itemBuilder: (context, index) {
          final newsItem = filteredNews[index];
          return _buildNewsCard(newsItem);
        },
      ),
    ];
  }

  Widget _buildCategoryCard(BuildContext context, String category, NewsProvider newsProvider) {
    final isSelected = newsProvider.selectedCategory == category;
    final newsCount = newsProvider.getNewsCountForCategory(category);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => newsProvider.selectCategory(category),
        child: Container(
          width: 140,
          height: 160,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PatternPainter(),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          newsProvider.getCategoryIcon(category),
                          size: 28,
                          color: isSelected 
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$newsCount مقال',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(news: news),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (news.image != null && news.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: ExtendedImage.network(
                  news.image!,
                  height: 200,
                  fit: BoxFit.cover,
                  cache: true,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.extendedImageLoadState == LoadState.failed) {
                      return const Center(
                        child: Icon(Icons.error_outline, size: 50),
                      );
                    }
                    return null;
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(news.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.category?.name ?? 'عام',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final newsProvider = context.read<NewsProvider>();
    await newsProvider.setDatabase(_selectedDatabase);
    await newsProvider.fetchNews(refresh: true);
    Provider.of<ClassesProvider>(context, listen: false)
        .fetchClasses(_selectedDatabase);
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final classesProvider = Provider.of<ClassesProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // تحديث عدد الأعمدة: 1 للشاشات الصغيرة، 2 للشاشات الكبيرة
    final crossAxisCount = screenWidth > 600 ? 2 : 1;
    // تعديل نسبة العرض إلى الارتفاع لتقليل الارتفاع
    final childAspectRatio = crossAxisCount == 1 ? 5.0 : 3.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Alemedu',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDatabase,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              dropdownColor: AppColors.primaryColor, 
              items: _countries.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
               onChanged: (String? newValue) async {
                if (newValue != null) {
                  setState(() {
                    _selectedDatabase = newValue;
                  });
                  // تحديث قاعدة البيانات في جميع الـ providers
                  await Provider.of<NewsProvider>(context, listen: false)
                      .setDatabase(newValue);
                  await Provider.of<NewsProvider>(context, listen: false)
                      .fetchNews(refresh: true);
                  classesProvider.fetchClasses(newValue);
                  Provider.of<ArticlesProvider>(context, listen: false)
                      .updateSelectedDatabase(newValue);
                  Provider.of<SubjectsProvider>(context, listen: false)
                      .updateSelectedDatabase(newValue);
                  Provider.of<SemestersProvider>(context, listen: false)
                      .updateSelectedDatabase(newValue);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.dashboard, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _bannerAdWidget(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (classesProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (classesProvider.error.isNotEmpty)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              classesProvider.error,
                              style: const TextStyle(color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  classesProvider.fetchClasses(_selectedDatabase),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 3.5,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: classesProvider.classes.length,
                            itemBuilder: (context, index) {
                              final classItem = classesProvider.classes[index];
                              return _buildGradeButton(classItem.gradeLevel, classItem.gradeName);
                            },
                          ),
                       const SizedBox(height: 32),
                       _buildNewsSection(),
                  ],
                ),
                  ),
              ),
          ],
        ),
      ),
    );
  }

  // Get icon for grade level
  IconData _getIconForGrade(int gradeLevel) {
    switch (gradeLevel) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      case 6:
        return Icons.looks_6;
      case 7:
        return Icons.auto_awesome;  // نجمة متوهجة للصف السابع
      case 8:
        return Icons.grade;  // نجمة للصف الثامن
      case 9:
        return Icons.stars;  // نجوم متعددة للصف التاسع
      case 10:
        return Icons.workspace_premium;  // أيقونة مميزة للصف العاشر
      case 11:
        return Icons.psychology;  // أيقونة تفكير للصف الحادي عشر
      case 12:
        return Icons.school;  // أيقونة مدرسة للصف الثاني عشر
      default:
        return Icons.class_;
    }
  }

  // Get gradient colors for grade level
  List<Color> _getGradientColorsForGrade(int gradeLevel) {
    if (gradeLevel <= 6) {
      // الصفوف الأساسية - تدرجات الأزرق
      return [Colors.blue[300]!, Colors.blue[600]!];
    } else if (gradeLevel <= 9) {
      // الصفوف المتوسطة - تدرجات الأخضر
      return [Colors.green[300]!, Colors.green[600]!];
    } else {
      // الصفوف الثانوية - تدرجات البنفسجي
      return [Colors.purple[300]!, Colors.purple[600]!];
    }
  }
}

// Custom Pattern Painter for Selected Category Cards
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final tileSize = 20.0;

    for (var i = 0; i < size.width / tileSize; i++) {
      for (var j = 0; j < size.height / tileSize; j++) {
        if ((i + j) % 2 == 0) {
          path.addRect(
            Rect.fromLTWH(
              i * tileSize,
              j * tileSize,
              tileSize,
              tileSize,
            ),
          );
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
