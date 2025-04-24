class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String subject;
  final String body;
  final bool read;
  final bool isImportant;
  final bool isDraft;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.subject,
    required this.body,
    required this.read,
    required this.isImportant,
    required this.isDraft,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      subject: json['subject'] as String,
      body: json['body'] as String,
      read: json['read'] == 1, 
      isImportant: json['is_important'] == 1,
      isDraft: json['is_draft'] == 1,
      isDeleted: json['is_deleted'] == 1,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'subject': subject,
      'body': body,
      'read': read ? 1 : 0,
      'is_important': isImportant ? 1 : 0,
      'is_draft': isDraft ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
