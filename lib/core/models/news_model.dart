class NewsModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? keywords;
  final int? authorId;
  final int? categoryId;
  final String createdAt;
  final String updatedAt;
  final CategoryModel? category;
  dynamic author;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.keywords,
    this.authorId,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.author,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      keywords: json['keywords'] as String?,
      authorId: json['author_id'] as int?,
      categoryId: json['category_id'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      category: json['category'] != null 
          ? CategoryModel.fromJson(json['category']) 
          : null,
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'keywords': keywords,
      'author_id': authorId,
      'category_id': categoryId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category?.toJson(),
      'author': author,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
