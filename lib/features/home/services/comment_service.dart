import 'package:alemedu_app/core/services/api_service.dart';
import '../models/comment_model.dart';
import '../models/reaction_model.dart';

class CommentService {
  final ApiService _apiService;
  String _selectedDatabase = 'jo';

  CommentService(this._apiService);

  void updateSelectedDatabase(String database) {
    _selectedDatabase = database;
  }

  Future<List<CommentModel>> getComments(int articleId) async {

    
    try {
      final response = await _apiService.get(
        '/$_selectedDatabase/lesson/articles/$articleId/comments',
      );
      

      
      if (response is Map && response['comments'] != null) {
        final List<dynamic> commentsJson = response['comments'];
        return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {

        return [];
      }
    } catch (e) {

      rethrow;
    }
  }

  Future<CommentModel> addComment({
    required String body,
    required int articleId,
  }) async {

    
    try {
      final response = await _apiService.post(
        '/$_selectedDatabase/lesson/articles/$articleId/comments',
        {
          'body': body,
          'database': _selectedDatabase,
        },
      );


      
      if (response == null || response['comment'] == null) {
        throw Exception('فشل في إضافة التعليق: لا توجد استجابة صالحة');
      }

      final commentJson = {
        ...response['comment'] as Map<String, dynamic>,
        'database': _selectedDatabase,
      };
      
      return CommentModel.fromJson(commentJson);
    } catch (e) {

      rethrow;
    }
  }

  Future<ReactionModel> addReaction({
    required int commentId,
    required String type,
  }) async {

    
    try {
      final response = await _apiService.post(        
        '/dashboard/reactions',
        {
          'comment_id': commentId,
          'type': type,
        },
      );
      

      
      // إنشاء كائن ReactionModel من البيانات المتوفرة
      return ReactionModel(
        id: response['reaction']?['id'] ?? 0,
        userId: response['reaction']?['user_id'] ?? 0,
        commentId: commentId,
        type: type,
      );
    } catch (e) {

      rethrow;
    }
  }
}
