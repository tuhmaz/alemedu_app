import 'package:flutter/material.dart';
import 'package:alemedu_app/features/home/models/comment_model.dart';
import 'package:alemedu_app/features/home/services/comment_service.dart';

class CommentsProvider extends ChangeNotifier {
  final CommentService _commentService;
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _error;

  CommentsProvider(this._commentService);

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateSelectedDatabase(String database) {
    _commentService.updateSelectedDatabase(database);
  }

  Future<void> loadComments(int articleId) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _comments = await _commentService.getComments(articleId);
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('خطأ في تحميل التعليقات: $e');
      _error = e.toString();
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> addComment({
    required String body,
    required int articleId,
  }) async {
    try {
      final newComment = await _commentService.addComment(
        body: body,
        articleId: articleId,
      );
      
      // إضافة التعليق الجديد إلى القائمة
      _comments = [...comments, newComment];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addReaction(int commentId, String type) async {
    try {
      await _commentService.addReaction(
        commentId: commentId,
        type: type,
      );
      
      // تحديث التعليق المحدد بالتفاعل الجديد
      final updatedComments = comments.map((comment) {
        if (comment.id == commentId) {
          final newReactionCounts = Map<String, int>.from(comment.reactionCounts);
          
          // إذا كان نفس النوع، نقوم بإزالته
          if (comment.userReactionType == type) {
            newReactionCounts[type] = (newReactionCounts[type] ?? 1) - 1;
            return comment.copyWith(
              reactionCounts: newReactionCounts,
              userReactionType: null,
            );
          } 
          // إذا كان هناك تفاعل سابق مختلف، نقوم بإزالته وإضافة الجديد
          else if (comment.userReactionType != null) {
            newReactionCounts[comment.userReactionType!] = 
              (newReactionCounts[comment.userReactionType!] ?? 1) - 1;
            newReactionCounts[type] = (newReactionCounts[type] ?? 0) + 1;
            return comment.copyWith(
              reactionCounts: newReactionCounts,
              userReactionType: type,
            );
          }
          // إضافة تفاعل جديد
          else {
            newReactionCounts[type] = (newReactionCounts[type] ?? 0) + 1;
            return comment.copyWith(
              reactionCounts: newReactionCounts,
              userReactionType: type,
            );
          }
        }
        return comment;
      }).toList();
      
      _comments = updatedComments;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
