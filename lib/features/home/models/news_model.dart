class NewsModel {
  final String? id;
  final String title;
  final String description;
  final String? image;
  final DateTime? createdAt;
  final CategoryModel? category;

  NewsModel({
    this.id,
    required this.title,
    required this.description,
    this.image,
    this.createdAt,
    this.category,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      category: json['category'] != null 
        ? CategoryModel.fromJson(json['category']) 
        : null,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
    );
  }
}
