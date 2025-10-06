import '../../domain/entities/character.dart';
import 'stroke_data_model.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.character,
    required super.pinyin,
    required super.meaning,
    required super.ttsUrl,
    required StrokeDataModel super.strokeData,
    required super.unitId,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> data, String id) {
    return CharacterModel(
      id: id,
      character: (data['hanzi'] ?? data['character'] ?? id).toString(),
      pinyin: data['pinyin']?.toString() ?? '',
      meaning: data['meaning']?.toString() ?? '',
      ttsUrl: data['ttsUrl']?.toString() ?? '',
      strokeData: StrokeDataModel.fromMap((data['strokeData'] as Map<String, dynamic>? ?? {})),
      unitId: (data['unitId'] ?? data['unit'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'hanzi': character,
        'character': character,
        'pinyin': pinyin,
        'meaning': meaning,
        'ttsUrl': ttsUrl,
        'strokeData': (strokeData as StrokeDataModel).toMap(),
        'unitId': unitId,
      };
}
