import 'stroke_data.dart';

class CharacterModel {
  const CharacterModel({
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.ttsUrl,
    required this.strokeData,
    required this.unitId,
  });

  final String character;
  final String pinyin;
  final String meaning;
  final String ttsUrl;
  final StrokeData strokeData;
  final String unitId;

  factory CharacterModel.fromMap(Map<String, dynamic> data, String id) {
    return CharacterModel(
      character: data['character']?.toString() ?? id,
      pinyin: data['pinyin']?.toString() ?? '',
      meaning: data['meaning']?.toString() ?? '',
      ttsUrl: data['ttsUrl']?.toString() ?? '',
      strokeData: StrokeData.fromMap(
        (data['strokeData'] as Map<String, dynamic>? ?? {}),
      ),
      unitId: data['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'character': character,
        'pinyin': pinyin,
        'meaning': meaning,
        'ttsUrl': ttsUrl,
        'strokeData': strokeData.toMap(),
        'unit': unitId,
      };
}
