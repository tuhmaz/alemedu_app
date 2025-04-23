class Author {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? profilePhotoUrl;

  Author({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.jobTitle,
    this.profilePhotoUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      jobTitle: json['job_title'],
      profilePhotoUrl: json['profile_photo_path'],
    );
  }
}

class Subject {
  final int id;
  final String subjectName;
  final int gradeLevel;

  Subject({
    required this.id,
    required this.subjectName,
    required this.gradeLevel,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      gradeLevel: json['grade_level'] ?? 0,
    );
  }
}

class Semester {
  final int id;
  final String semesterName;
  final int gradeLevel;

  Semester({
    required this.id,
    required this.semesterName,
    required this.gradeLevel,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] ?? 0,
      semesterName: json['semester_name'] ?? '',
      gradeLevel: json['grade_level'] ?? 0,
    );
  }
}

class Keyword {
  final int id;
  final String keyword;

  Keyword({
    required this.id,
    required this.keyword,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'] ?? 0,
      keyword: json['keyword'] ?? '',
    );
  }
}

class ArticleFile {
  final int id;
  final String fileName;
  final String fileType;
  final String filePath;
  final String fileCategory;
  final int downloadCount;
  final int viewsCount;

  ArticleFile({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.filePath,
    required this.fileCategory,
    required this.downloadCount,
    required this.viewsCount,
  });

  factory ArticleFile.fromJson(Map<String, dynamic> json) {
    return ArticleFile(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      filePath: json['file_path'] ?? '',
      fileCategory: json['file_category'] ?? '',
      downloadCount: json['download_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
    );
  }
}

class ArticleModel {
  final int id;
  final String title;
  final String content;
  final String? contentWithKeywords;
  final String category;
  final String gradeLevel;
  final String filePath;
  final int visitCount;
  final int downloadCount;
  final String? fileCategory;
  final Author? author;
  final Subject? subject;
  final Semester? semester;
  final List<Keyword> keywords;
  final List<ArticleFile> files;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.contentWithKeywords,
    required this.category,
    required this.gradeLevel,
    required this.filePath,
    required this.visitCount,
    required this.downloadCount,
    this.fileCategory,
    this.author,
    this.subject,
    this.semester,
    required this.keywords,
    required this.files,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // استخراج اسم المرحلة الدراسية من الاستجابة
    String gradeName = '';
    
    // محاولة الحصول على اسم المرحلة من school_class
    if (json['school_class'] != null) {
      gradeName = json['school_class']['grade_name'] ?? '';
    }
    
    // إذا لم نجد في school_class، نبحث في subject.school_class
    if (gradeName.isEmpty && json['subject'] != null && json['subject']['school_class'] != null) {
      gradeName = json['subject']['school_class']['grade_name'] ?? '';
    }
    
    // إذا لم نجد في subject.school_class، نبحث في grade_name مباشرة
    if (gradeName.isEmpty && json['grade_name'] != null) {
      gradeName = json['grade_name'];
    }
    
    // إذا لم نجد في أي مكان، نستخدم grade_level كاحتياطي
    if (gradeName.isEmpty && json['grade_level'] != null) {
      gradeName = json['grade_level'].toString();
    }

    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      contentWithKeywords: json['content_with_keywords'],
      category: json['category'] ?? '',
      gradeLevel: gradeName,
      filePath: json['file_path'] ?? '',
      visitCount: json['visit_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      fileCategory: json['file_category'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      semester: json['semester'] != null ? Semester.fromJson(json['semester']) : null,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((keyword) => Keyword.fromJson(keyword))
              .toList() ??
          [],
      files: (json['files'] as List<dynamic>?)
              ?.map((file) => ArticleFile.fromJson(file))
              .toList() ??
          [],
    );
  }

  String get type {
    if (files.isNotEmpty) {
      return files.first.fileType;
    }
    return '';
  }

  String get mainFilePath {
    if (files.isNotEmpty) {
      return files.first.filePath;
    }
    return '';
  }
}
