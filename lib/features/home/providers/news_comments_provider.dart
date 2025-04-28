import 'package:flutter/material.dart';
import '../services/news_comment_service.dart';
import '../models/comment_model.dart';

class NewsCommentsProvider extends ChangeNotifier {
  NewsCommentService _commentService;
  final Map<int, List<CommentModel>> _commentsMap = {};
  final Map<int, bool> _loadingMap = {};
  final Map<int, String?> _errorMap = {};

  NewsCommentsProvider(this._commentService);

  List<CommentModel> getComments(int newsId) => _commentsMap[newsId] ?? [];
  bool isLoading(int newsId) => _loadingMap[newsId] ?? false;
  String? getError(int newsId) => _errorMap[newsId];

  void updateCommentService(NewsCommentService service) {
    _commentService = service;
    // إعادة تحميل التعليقات للأخبار المفتوحة حالياً
    for (var newsId in _commentsMap.keys) {
      loadComments(newsId);
    }
  }

  Future<void> loadComments(int newsId) async {
    _loadingMap[newsId] = true;
    _errorMap[newsId] = null;
    notifyListeners();

    try {
      final comments = await _commentService.getNewsComments(newsId);
      _commentsMap[newsId] = comments;
      _errorMap[newsId] = null;
    } catch (e) {
      _errorMap[newsId] = 'حدث خطأ في تحميل التعليقات';
    } finally {
      _loadingMap[newsId] = false;
      notifyListeners();
    }
  }

  Future<void> addComment(String body, int newsId) async {
    try {
      final newComment = await _commentService.addComment(
        body: body,
        newsId: newsId,
      );
      
      if (!_commentsMap.containsKey(newsId)) {
        _commentsMap[newsId] = [];
      }
      _commentsMap[newsId]!.add(newComment);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReaction(int commentId, String type, int newsId) async {
    try {
      await _commentService.addReaction(
        commentId: commentId,
        type: type,
      );

      if (_commentsMap.containsKey(newsId)) {
        final comments = _commentsMap[newsId]!;
        final commentIndex = comments.indexWhere((c) => c.id == commentId);
        
         if (commentIndex != -1) {
        final comment = comments[commentIndex];
        await _commentService.addReaction(
          commentId: commentId,
          type: type,
        );
        final newReactionCounts = Map<String, int>.from(comment.reactionCounts);
        if (comment.userReactionType == type) {
          // If the same type, remove the reaction
          newReactionCounts[type] = comment.getReactionCount(type) - 1;
          if (newReactionCounts[type] == 0) {
            newReactionCounts.remove(type);
          }
          comments[commentIndex] = comment.copyWith(
            reactionCounts: newReactionCounts,
            userReactionType: null,
          );
        } else {
          // If different type, add the new reaction and remove the old one
          if (comment.userReactionType != null) {
            final oldCount = comment.getReactionCount(comment.userReactionType!);
            newReactionCounts[comment.userReactionType!] = oldCount - 1;
            if (newReactionCounts[comment.userReactionType!] == 0) {
              newReactionCounts.remove(comment.userReactionType);
            }
          }
          newReactionCounts[type] = comment.getReactionCount(type) + 1;
          comments[commentIndex] = comment.copyWith(
            reactionCounts: newReactionCounts,
            userReactionType: type,
          );
        }
          _commentsMap[newsId] = comments;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  void updateSelectedDatabase(String database) {
    _commentService.updateSelectedDatabase(database);
  }

  void clearComments(int newsId) {
    _commentsMap.remove(newsId);
    _loadingMap.remove(newsId);
    _errorMap.remove(newsId);
    notifyListeners();
  }
}
