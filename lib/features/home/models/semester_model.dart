class SemesterModel {
  final int id;
  final String semesterName;
  final int gradeLevel;

  SemesterModel({
    required this.id,
    required this.semesterName,
    required this.gradeLevel,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as int,
      semesterName: (json['semesterName'] ?? json['semester_name']) as String,
      gradeLevel: (json['gradeLevel'] ?? json['grade_level']) as int,
    );
  }

  @override
  String toString() {
    return 'SemesterModel(id: $id, semesterName: $semesterName, gradeLevel: $gradeLevel)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semesterName': semesterName,
      'gradeLevel': gradeLevel,
    };
  }
}
