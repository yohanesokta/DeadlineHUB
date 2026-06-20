class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  final String webViewLink;
  final DateTime modifiedTime;
  final String? thumbnailLink;

  const DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.webViewLink,
    required this.modifiedTime,
    this.thumbnailLink,
  });
}
