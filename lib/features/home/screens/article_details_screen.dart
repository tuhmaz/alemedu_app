import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:alemedu_app/features/home/providers/articles_provider.dart';
import 'package:alemedu_app/features/home/models/article_model.dart';
import 'package:alemedu_app/features/home/screens/download_screen.dart';
import 'package:alemedu_app/core/constants/colors.dart';
import 'package:alemedu_app/features/home/providers/comments_provider.dart';
import 'package:alemedu_app/features/auth/providers/auth_provider.dart';
import 'package:alemedu_app/features/home/models/comment_model.dart';
import 'package:alemedu_app/features/home/models/reaction_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ArticleDetailsScreen extends StatefulWidget {
  final int articleId;
  final String subjectName;
  final String categoryLabel;

  const ArticleDetailsScreen({
    super.key,
    required this.articleId,
    required this.subjectName,
    required this.categoryLabel,
  });

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  bool _isFirstLoad = true;
  final TextEditingController _commentController = TextEditingController();

  int _getTotalDownloads(ArticleModel article) {
    return article.files.fold(0, (sum, file) => sum + file.downloadCount);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isFirstLoad) {

      
      // Get the selected database from ArticlesProvider
      final articlesProvider = Provider.of<ArticlesProvider>(context, listen: false);
      final selectedDatabase = articlesProvider.selectedDatabase;

      
      // Update the database in CommentsProvider
      final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
      commentsProvider.updateSelectedDatabase(selectedDatabase);
      
      // Fetch article details and comments
      await articlesProvider.fetchArticleDetails(widget.articleId);
      await commentsProvider.loadComments(widget.articleId);
      
      _isFirstLoad = false;

    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _buildBreadcrumb(ArticleModel article) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                        fontSize: 13,
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
                  Navigator.of(context).pop();  // Back to articles
                  Navigator.of(context).pop();  // Back to subject content
                  Navigator.of(context).pop();  // Back to subjects
                },
                child: const Text(
                  'المواد الدراسية',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
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
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();  // Back to articles
                  Navigator.of(context).pop();  // Back to subject content
                },
                child: Text(
                  widget.subjectName,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
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
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  widget.categoryLabel,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
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
              Text(
                article.title,
                style: const TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(ArticleModel article) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Header
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'المشاهدات: ${article.visitCount}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.download, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'التحميلات: ${_getTotalDownloads(article)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    if (article.author != null)
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            article.author!.name,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Article Info Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildInfoCard(
                  icon: Icons.school,
                  title: 'المرحلة الدراسية',
                  value: article.gradeLevel,
                ),
                _buildInfoCard(
                  icon: Icons.book,
                  title: 'المادة',
                  value: article.subject?.subjectName ?? 'غير محدد',
                ),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'الفصل الدراسي',
                  value: article.semester?.semesterName ?? 'غير محدد',
                ),
                if (article.files.isNotEmpty && article.files.first.fileCategory.isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.folder,
                    title: 'تصنيف الملف',
                    value: article.files.first.fileCategory,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Keywords
          if (article.keywords.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الكلمات المفتاحية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: article.keywords.map((keyword) {
                      return Chip(
                        label: Text(keyword.keyword),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2)),
                        labelStyle: const TextStyle(color: AppColors.primaryColor),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Article Content
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Html(
                data: article.content.replaceAll(
                  RegExp(r'src="\/storage'),
                  'src="https://alemedu.com/storage'

                ),
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.3),
                    textAlign: TextAlign.right,
                    direction: TextDirection.rtl,
                    color: const Color(0xFF37474F),
                    fontFamily: 'Tajawal',
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "img": Style(
                    width: Width(MediaQuery.of(context).size.width - 72),
                    alignment: Alignment.center,
                    margin: Margins.only(bottom: 4),
                    display: Display.block,
                  ),
                  "p": Style(
                    margin: Margins.symmetric(vertical: 2),
                  ),
                  "br": Style(
                    height: Height(0),
                    margin: Margins.zero,
                  ),
                  "a": Style(
                    color: AppColors.primaryColor,
                    textDecoration: TextDecoration.none,
                  ),
                },

              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attached Files
          if (article.files.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الملفات المرفقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...article.files.map((file) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileIcon(file.fileType),
                          color: AppColors.primaryColor,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              file.fileName ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DownloadScreen(
                                fileUrl: 'https://alemedu.com/storage/${file.filePath}',
                                fileName: file.fileName ?? 'الملف',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Comments Section
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التعليقات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<CommentsProvider>(
                  builder: (context, commentsProvider, _) {
                    if (commentsProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // عرض التعليقات الحالية
                        ...commentsProvider.comments.map((comment) => _buildCommentItem(comment)).toList(),
                        const SizedBox(height: 16),
                        // نموذج إضافة تعليق جديد
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            if (!authProvider.isAuthenticated) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text('سجل دخول للتعليق'),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'اكتب تعليقك هنا...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () async {
                                        final commentText = _commentController.text.trim();
                                        if (commentText.isNotEmpty) {
                                          try {
                                            await Provider.of<CommentsProvider>(context, listen: false).addComment(
                                              body: commentText,
                                              articleId: widget.articleId,
                                            );
                                            _commentController.clear();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  controller: _commentController,
                                  maxLines: 3,
                                ),
                                if (Provider.of<CommentsProvider>(context, listen: false).error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      Provider.of<CommentsProvider>(context, listen: false).error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Article Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final selectedDatabase = Provider.of<ArticlesProvider>(context, listen: false).selectedDatabase;

                      final link = Uri.encodeFull(
                        'https://alemedu.com/$selectedDatabase/articles/${article.id}',
                      );

                      Share.share(
                        '📄 مقال: ${article.title}\n\n🔗 رابط المقال: $link',
                        subject: article.title,
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: article.title));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الرابط')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ الرابط'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required String type,
    required int count,
    required bool isSelected,
    required Function() onPressed,
  }) {
    final color = type == 'like' ? Colors.blue 
                : type == 'love' ? Colors.red 
                : Colors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: comment.user.name.isNotEmpty
                      ? Text(
                          comment.user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user.name.isNotEmpty ? comment.user.name : 'مستخدم',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'ar'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.body),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildReactionButton(
                  icon: Icons.thumb_up_outlined,
                  type: 'like',
                  count: comment.getReactionCount('like'),
                  isSelected: comment.hasUserReacted('like'),
                  onPressed: () => _handleReaction(comment.id, 'like'),
                ),
                const SizedBox(width: 8),
                _buildReactionButton(
                  icon: Icons.favorite_outline,
                  type: 'love',
                  count: comment.getReactionCount('love'),
                  isSelected: comment.hasUserReacted('love'),
                  onPressed: () => _handleReaction(comment.id, 'love'),
                ),
                const SizedBox(width: 8),
                _buildReactionButton(
                  icon: Icons.sentiment_satisfied_outlined,
                  type: 'haha',
                  count: comment.getReactionCount('haha'),
                  isSelected: comment.hasUserReacted('haha'),
                  onPressed: () => _handleReaction(comment.id, 'haha'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReaction(int commentId, String type) async {
    try {
      final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
      await commentsProvider.addReaction(commentId, type);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Consumer<ArticlesProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.selectedArticle?.title ?? 'تحميل...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: Consumer<ArticlesProvider>(
        builder: (context, provider, child) {
          if (provider.selectedArticle == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final article = provider.selectedArticle!;
          return Column(
            children: [
              _buildBreadcrumb(article),
              Expanded(
                child: _buildArticleContent(article),
              ),
            ],
          );
        },
      ),
    );
  }
}
