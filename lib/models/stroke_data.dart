class StrokeData {
  const StrokeData({
    required this.width,
    required this.height,
    required this.paths,
  });

  final int width;
  final int height;
  final List<String> paths;

  factory StrokeData.fromMap(Map<String, dynamic> data) {
    return StrokeData(
      width: (data['width'] as num?)?.toInt() ?? 100,
      height: (data['height'] as num?)?.toInt() ?? 100,
      paths: (data['paths'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'width': width,
        'height': height,
        'paths': paths,
      };
}
