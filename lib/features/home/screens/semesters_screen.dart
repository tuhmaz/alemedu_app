import 'package:flutter/material.dart';

class SemestersScreen extends StatelessWidget {
  final int subjectId;
  final String subjectName;

  const SemestersScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('صفحة الفصول الدراسية قيد التطوير'),
      ),
    );
  }
}
