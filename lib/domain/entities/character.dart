import 'stroke_data.dart';

class Character {
  const Character({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.ttsUrl,
    required this.strokeData,
    required this.unitId,
  });

  final String id;
  final String character;
  final String pinyin;
  final String meaning;
  final String ttsUrl;
  final StrokeData strokeData;
  final String unitId;
}
