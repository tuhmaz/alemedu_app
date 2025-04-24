class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? jobTitle;
  final String? gender;
  final String? country;
  final String? socialLinks;
  final String? bio;
  final String status;
  final String? lastActivity;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.jobTitle = '',
    this.gender = '',
    this.country = '',
    this.socialLinks = '',
    this.bio = '',
    required this.status,
    this.lastActivity,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProfileModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone']?.toString() ?? '',
        jobTitle: json['job_title']?.toString() ?? '',
        gender: json['gender']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        socialLinks: json['social_links']?.toString() ?? '',
        bio: json['bio']?.toString() ?? '',
        status: json['status']?.toString() ?? 'offline',
        lastActivity: json['last_activity']?.toString(),
        avatar: json['avatar']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'job_title': jobTitle,
      'gender': gender,
      'country': country,
      'social_links': socialLinks,
      'bio': bio,
      'status': status,
      'last_activity': lastActivity,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
