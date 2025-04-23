class SubjectModel {
  final int id;
  final String subjectName;
  final int gradeLevel;

  SubjectModel({
    required this.id,
    required this.subjectName,
    required this.gradeLevel,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      gradeLevel: json['grade_level'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'SubjectModel(id: $id, subjectName: $subjectName, gradeLevel: $gradeLevel)';
  }
}

class ClassModel {
  final int id;
  final String gradeName;
  final int gradeLevel;
  final List<SubjectModel> subjects;

  ClassModel({
    required this.id,
    required this.gradeName,
    required this.gradeLevel,
    required this.subjects,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    List<SubjectModel> subjectsList = [];
    if (json['subjects'] != null) {
      subjectsList = (json['subjects'] as List)
          .map((subject) => SubjectModel.fromJson(subject as Map<String, dynamic>))
          .toList();
    }
    
    return ClassModel(
      id: json['id'] as int? ?? 0,
      gradeName: json['grade_name'] as String? ?? '',
      gradeLevel: json['grade_level'] as int? ?? 0,
      subjects: subjectsList,
    );
  }

  @override
  String toString() {
    return 'ClassModel(id: $id, gradeName: $gradeName, gradeLevel: $gradeLevel, subjects: ${subjects.length})';
  }
}
