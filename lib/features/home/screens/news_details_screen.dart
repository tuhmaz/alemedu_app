import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/news_model.dart';
import '../../../core/constants/colors.dart';
import 'package:extended_image/extended_image.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/news_comments_provider.dart';
import '../widgets/comment_list.dart';
import '../widgets/comment_input.dart';

class NewsDetailsScreen extends StatefulWidget {
  final NewsModel news;

  const NewsDetailsScreen({
    Key? key,
    required this.news,
  }) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل التعليقات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCommentsProvider>().loadComments(widget.news.id);
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.news.category?.name ?? 'تفاصيل الخبر',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${widget.news.title}\n\n${widget.news.description}\n\nشارك عبر تطبيق علم',
                subject: widget.news.title,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.news.image != null && widget.news.image!.isNotEmpty)
              ExtendedImage.network(
                widget.news.image!,
                fit: BoxFit.cover,
                height: 250,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
                        _formatDate(widget.news.createdAt),
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
                          widget.news.category?.name ?? 'عام',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.news.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التعليقات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommentInput(
                    onSubmit: (text) {
                      if (text.isNotEmpty) {
                        context.read<NewsCommentsProvider>().addComment(
                              text,
                              widget.news.id,
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<NewsCommentsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading(widget.news.id)) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final error = provider.getError(widget.news.id);
                      if (error != null) {
                        return Center(
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final comments = provider.getComments(widget.news.id);
                      if (comments.isEmpty) {
                        return const Center(
                          child: Text('لا توجد تعليقات بعد'),
                        );
                      }

                      return CommentList(
                        comments: comments,
                        onReaction: (commentId, type) {
                          provider.addReaction(commentId, type, widget.news.id);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
