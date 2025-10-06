class LessonUnit {
  const LessonUnit({
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
}
