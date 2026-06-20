class AcademicEmail {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final String? body;
  final String? bodySummary;
  final DateTime receivedAt;
  final bool isAcademic;
  final bool isPriority;

  const AcademicEmail({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    this.body,
    this.bodySummary,
    required this.receivedAt,
    required this.isAcademic,
    this.isPriority = false,
  });

  AcademicEmail copyWith({
    String? id,
    String? sender,
    String? subject,
    String? snippet,
    String? body,
    String? bodySummary,
    DateTime? receivedAt,
    bool? isAcademic,
    bool? isPriority,
  }) {
    return AcademicEmail(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      snippet: snippet ?? this.snippet,
      body: body ?? this.body,
      bodySummary: bodySummary ?? this.bodySummary,
      receivedAt: receivedAt ?? this.receivedAt,
      isAcademic: isAcademic ?? this.isAcademic,
      isPriority: isPriority ?? this.isPriority,
    );
  }
}
