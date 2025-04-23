class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  factory UserModel.empty() {
    return UserModel(
      id: 0,
      name: '',
      email: '',
      avatar: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
