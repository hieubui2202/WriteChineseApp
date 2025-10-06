import 'package:get/get.dart';

import '../models/character_model.dart';
import 'progress_controller.dart';

class ReviewController extends GetxController {
  ReviewController(this.progressController);

  final ProgressController progressController;

  final RxInt index = 0.obs;

  List<CharacterModel> get masteredCharacters {
    final result = <CharacterModel>[];
    for (final unit in progressController.lessons) {
      final progress = progressController.current?.progress[unit.id] ?? {};
      for (final characterId in unit.characterIds) {
        final entry = progress[characterId];
        if (entry != null && entry.completed && entry.score >= 60) {
          final character = progressController.characters
              .firstWhereOrNull((element) => element.character == characterId);
          if (character != null) {
            result.add(character);
          }
        }
      }
    }
    return result;
  }

  void next() {
    final total = masteredCharacters.length;
    if (total <= 1) return;
    index.value = (index.value + 1) % total;
  }

  void previous() {
    final total = masteredCharacters.length;
    if (total <= 1) return;
    index.value = (index.value - 1 + total) % total;
  }
}
