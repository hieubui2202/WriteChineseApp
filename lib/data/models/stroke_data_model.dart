import '../../domain/entities/stroke_data.dart';

class StrokeDataModel extends StrokeData {
  const StrokeDataModel({
    required super.width,
    required super.height,
    required super.paths,
  });

  factory StrokeDataModel.fromMap(Map<String, dynamic> data) {
    return StrokeDataModel(
      width: (data['width'] as num?)?.toDouble() ?? 100,
      height: (data['height'] as num?)?.toDouble() ?? 100,
      paths: (data['paths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'width': width,
        'height': height,
        'paths': paths,
      };
}
