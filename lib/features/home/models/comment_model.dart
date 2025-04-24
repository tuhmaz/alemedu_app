import '../../../features/auth/models/user_model.dart';

class CommentModel {
  final int id;
  final String body;
  final int commentableId;
  final String commentableType;
  final int userId;
  final UserModel user;
  final Map<String, int> reactionCounts;
  final String? userReactionType;
  final DateTime createdAt;
  final String database;

  CommentModel({
    required this.id,
    required this.body,
    required this.commentableId,
    required this.commentableType,
    required this.userId,
    required this.user,
    required this.reactionCounts,
    this.userReactionType,
    required this.createdAt,
    required this.database,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    try {
      return CommentModel(
        id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
        body: json['body']?.toString() ?? '',
        commentableId: json['commentable_id'] is String 
          ? int.parse(json['commentable_id']) 
          : json['commentable_id'] ?? 0,
        commentableType: json['commentable_type']?.toString() ?? '',
        userId: json['user_id'] is String 
          ? int.parse(json['user_id']) 
          : json['user_id'] ?? 0,
        user: json['user'] != null ? UserModel.fromJson(json['user']) : UserModel.empty(),
        reactionCounts: _parseReactionCounts(json['reaction_counts']),
        userReactionType: json['user_reaction_type']?.toString(),
        createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
        database: json['database']?.toString() ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Map<String, int> _parseReactionCounts(dynamic counts) {
    if (counts == null) return {};
    
    final Map<String, int> result = {};
    if (counts is List) {
      // إذا كان التنسيق قائمة، نقوم بتحويلها إلى Map
      for (var item in counts) {
        if (item is Map<String, dynamic>) {
          final type = item['type'] as String;
          final count = item['count'] as int;
          result[type] = count;
        }
      }
    } else if (counts is Map) {
      // إذا كان التنسيق Map، نقوم بتحويله مباشرة
      counts.forEach((key, value) {
        result[key.toString()] = value is int ? value : int.parse(value.toString());
      });
    }
    return result;
  }

  bool hasUserReacted(String type) {
    return userReactionType == type;
  }

  int getReactionCount(String type) {
    return reactionCounts[type] ?? 0;
  }

  CommentModel copyWith({
    int? id,
    String? body,
    int? commentableId,
    String? commentableType,
    int? userId,
    UserModel? user,
    Map<String, int>? reactionCounts,
    String? userReactionType,
    DateTime? createdAt,
    String? database,
  }) {
    return CommentModel(
      id: id ?? this.id,
      body: body ?? this.body,
      commentableId: commentableId ?? this.commentableId,
      commentableType: commentableType ?? this.commentableType,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      userReactionType: userReactionType ?? this.userReactionType,
      createdAt: createdAt ?? this.createdAt,
      database: database ?? this.database,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'commentable_id': commentableId,
      'commentable_type': commentableType,
      'database': database,
    };
  }
}
