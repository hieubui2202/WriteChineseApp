import 'package:get/get.dart';

import '../models/character_model.dart';
import '../models/lesson_unit_model.dart';
import 'progress_controller.dart';

class HomeController extends GetxController {
  HomeController(this.progressController);

  final ProgressController progressController;

  List<LessonUnitModel> get units => List<LessonUnitModel>.from(progressController.lessons);
  List<CharacterModel> get characters => progressController.characters;

  LessonUnitModel? findUnit(String unitId) {
    try {
      return units.firstWhere((element) => element.id == unitId);
    } catch (_) {
      return null;
    }
  }

  CharacterModel? nextCharacterForUnit(LessonUnitModel unit) {
    final progress = progressController.current?.progress[unit.id] ?? {};
    final available = unit.characterIds;
    for (final id in available) {
      if (!progress.containsKey(id) || progress[id]!.completed == false) {
        return characters.firstWhereOrNull((element) => element.character == id);
      }
    }
    return characters.firstWhereOrNull((element) => element.character == available.first);
  }

}
