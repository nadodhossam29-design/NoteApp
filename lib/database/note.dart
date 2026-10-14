import 'package:floor/floor.dart';

@entity
class Note {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String content;

  // Optional location fields
  final double? latitude;
  final double? longitude;

  final String createdAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });
}
