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
      id: json['id'] as int,
      subjectName: json['subject_name'] as String? ?? json['name'] as String, // Try both field names
      gradeLevel: json['grade_level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_name': subjectName,
      'grade_level': gradeLevel,
    };
  }

  @override
  String toString() {
    return 'SubjectModel(id: $id, subjectName: $subjectName, gradeLevel: $gradeLevel)';
  }
}
