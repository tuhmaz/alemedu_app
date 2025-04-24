import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/semesters_provider.dart';
import '../../../core/constants/colors.dart';
import './articles_screen.dart';

class SubjectContentScreen extends StatefulWidget {
  final String subjectName;
  final int subjectId;
  final String? gradeName;

  const SubjectContentScreen({
    super.key,
    required this.subjectName,
    required this.subjectId,
    this.gradeName,
  });

  @override
  State<SubjectContentScreen> createState() => _SubjectContentScreenState();
}

class _SubjectContentScreenState extends State<SubjectContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SemestersProvider>().fetchSemesters(widget.subjectId);
    });
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.breadcrumbBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Row(
              children: [
                Icon(
                  Icons.home,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  'الرئيسية',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.greyColor,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Text(
              'المواد الدراسية',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.greyColor,
            ),
          ),
          Expanded(
            child: Text(
              widget.subjectName,
              style: const TextStyle(
                color: AppColors.greyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String category,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterSection(String title, int semesterId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  _buildResourceButton(
                    title: 'خطط دراسية',
                    icon: Icons.book_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlesScreen(
                            title: 'خطط دراسية - ${widget.subjectName}',
                            subjectId: widget.subjectId,
                            semesterId: semesterId,
                            category: 'plans',
                            subjectName: widget.subjectName,
                            categoryLabel: 'خطط دراسية',
                          ),
                        ),
                      );
                    },
                    color: const Color(0xFF4CAF50),
                    category: 'plans',
                  ),
                  _buildResourceButton(
                    title: 'أوراق عمل',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlesScreen(
                            title: 'أوراق عمل - ${widget.subjectName}',
                            subjectId: widget.subjectId,
                            semesterId: semesterId,
                            category: 'papers',
                            subjectName: widget.subjectName,
                            categoryLabel: 'أوراق عمل',
                          ),
                        ),
                      );
                    },
                    color: const Color(0xFF2196F3),
                    category: 'papers',
                  ),
                ],
              ),
              Row(
                children: [
                  _buildResourceButton(
                    title: 'اختبارات',
                    icon: Icons.quiz_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlesScreen(
                            title: 'اختبارات - ${widget.subjectName}',
                            subjectId: widget.subjectId,
                            semesterId: semesterId,
                            category: 'tests',
                            subjectName: widget.subjectName,
                            categoryLabel: 'اختبارات',
                          ),
                        ),
                      );
                    },
                    color: const Color(0xFF9C27B0),
                    category: 'tests',
                  ),
                  _buildResourceButton(
                    title: 'كتب مدرسية',
                    icon: Icons.menu_book_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlesScreen(
                            title: 'كتب مدرسية - ${widget.subjectName}',
                            subjectId: widget.subjectId,
                            semesterId: semesterId,
                            category: 'books',
                            subjectName: widget.subjectName,
                            categoryLabel: 'كتب مدرسية',
                          ),
                        ),
                      );
                    },
                    color: const Color(0xFFFF9800),
                    category: 'books',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.subjectName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildBreadcrumb(),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<SemestersProvider>(
                builder: (context, semestersProvider, child) {
                  if (semestersProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (semestersProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            semestersProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              semestersProvider.fetchSemesters(widget.subjectId);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (var semester in semestersProvider.semesters)
                        _buildSemesterSection(semester.semesterName, semester.id),
                    ],
                  );

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
