import 'package:get/get.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/lesson_unit.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/usecases/bootstrap_progress.dart';
import '../../domain/usecases/clear_progress_cache.dart';
import '../../domain/usecases/record_lesson_result.dart';

class ProgressController extends GetxController {
  ProgressController({
    required RecordLessonResult recordLessonResult,
    required ClearProgressCache clearProgressCache,
  })  : _recordLessonResult = recordLessonResult,
        _clearProgressCache = clearProgressCache;

  final RecordLessonResult _recordLessonResult;
  final ClearProgressCache _clearProgressCache;

  final Rx<UserProgress?> _progress = Rx<UserProgress?>(null);
  final RxList<Character> characters = <Character>[].obs;
  final RxList<LessonUnit> units = <LessonUnit>[].obs;
  final RxBool isLoading = false.obs;

  UserProgress? get current => _progress.value;

  void setBootstrap(BootstrapProgressResult result) {
    isLoading.value = true;
    characters.clear();
    units.clear();
    _progress.value = result.progress;
    characters.assignAll(result.characters);
    units.assignAll(result.units);
    isLoading.value = false;
  }

  Future<void> recordResult({
    required Character character,
    required String unitId,
    required int score,
    required bool success,
  }) async {
    final existing = current;
    if (existing == null) return;
    final updated = await _recordLessonResult(
      existing,
      RecordLessonResultParams(
        character: character,
        unitId: unitId,
        score: score,
        success: success,
      ),
    );
    _progress.value = updated;
  }

  int unitScore(String unitId) {
    final progress = current?.progress[unitId];
    if (progress == null || progress.isEmpty) {
      return 0;
    }
    final total = progress.values.fold<int>(0, (sum, item) => sum + item.score);
    return total ~/ progress.length;
  }

  bool isMastered(String unitId, String characterId) {
    final unit = current?.progress[unitId];
    if (unit == null) return false;
    final entry = unit[characterId];
    return entry?.completed == true && (entry?.score ?? 0) >= 80;
  }

  LessonUnit? findUnitById(String id) {
    return units.firstWhereOrNull((unit) => unit.id == id);
  }

  Character? findCharacter(String id) {
    return characters.firstWhereOrNull((character) => character.id == id);
  }

  Future<void> clearProgress() async {
    _progress.value = null;
    characters.clear();
    units.clear();
    await _clearProgressCache();
  }
}
