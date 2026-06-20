class ClassroomAssignment {
  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final String? description;
  final DateTime? dueTime;
  final String alternateLink;
  final bool isSubmitted;

  const ClassroomAssignment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    this.description,
    this.dueTime,
    required this.alternateLink,
    required this.isSubmitted,
  });

  ClassroomAssignment copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? title,
    String? description,
    DateTime? dueTime,
    String? alternateLink,
    bool? isSubmitted,
  }) {
    return ClassroomAssignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      description: description ?? this.description,
      dueTime: dueTime ?? this.dueTime,
      alternateLink: alternateLink ?? this.alternateLink,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
