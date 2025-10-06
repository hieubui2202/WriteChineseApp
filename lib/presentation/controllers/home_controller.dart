import 'package:get/get.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/lesson_unit.dart';
import 'progress_controller.dart';

class HomeController extends GetxController {
  HomeController(this.progressController);

  final ProgressController progressController;

  List<LessonUnit> get units => List<LessonUnit>.from(progressController.units);
  List<Character> get characters => progressController.characters;

  LessonUnit? findUnit(String unitId) {
    try {
      return units.firstWhere((element) => element.id == unitId);
    } catch (_) {
      return null;
    }
  }

  Character? nextCharacterForUnit(LessonUnit unit) {
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
