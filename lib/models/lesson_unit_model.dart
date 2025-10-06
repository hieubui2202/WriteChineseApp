class LessonUnitModel {
  const LessonUnitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.characterIds,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final List<String> characterIds;
  final int color;

  factory LessonUnitModel.fromMap(Map<String, dynamic> data, String id) {
    return LessonUnitModel(
      id: id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      characterIds: (data['characters'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      color: int.tryParse(
            (data['color']?.toString() ?? '').replaceAll('#', ''),
            radix: 16,
          ) ??
          0xFF00CFFF,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'characters': characterIds,
        'color': '#${color.toRadixString(16).padLeft(8, '0').substring(2)}',
      };
}
