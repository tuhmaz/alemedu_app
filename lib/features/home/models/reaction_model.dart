class ReactionModel {
  final int id;
  final int userId;
  final int commentId;
  final String type;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.commentId,
    required this.type,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'],
      userId: json['user_id'],
      commentId: json['comment_id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'type': type,
    };
  }
}
