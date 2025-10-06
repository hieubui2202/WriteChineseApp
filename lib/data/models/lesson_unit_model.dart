import '../../domain/entities/lesson_unit.dart';

class LessonUnitModel extends LessonUnit {
  const LessonUnitModel({
    required super.id,
    required super.title,
    required super.description,
    required super.characterIds,
    required super.color,
  });

  factory LessonUnitModel.fromMap(Map<String, dynamic> data, String id) {
    return LessonUnitModel(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      characterIds: (data['characters'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      color: int.tryParse((data['color']?.toString() ?? '').replaceAll('#', ''), radix: 16) ?? 0xFF00CFFF,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'characters': characterIds,
        'color': '#${color.toRadixString(16).padLeft(8, '0').substring(2)}',
      };
}
