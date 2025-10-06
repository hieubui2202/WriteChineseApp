import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/character_model.dart';
import '../models/lesson_unit_model.dart';
import '../models/user_progress_model.dart';
import '../services/firebase_service.dart';
import '../services/progress_local_service.dart';

class ProgressController extends GetxController {
  ProgressController({FirebaseService? firebaseService, ProgressLocalService? localService})
      : _firebaseService = firebaseService ?? FirebaseService(),
        _localService = localService ?? ProgressLocalService();

  final FirebaseService _firebaseService;
  final ProgressLocalService _localService;

  final Rx<UserProgressModel?> _progress = Rx<UserProgressModel?>(null);
  final RxList<CharacterModel> characters = <CharacterModel>[].obs;
  final RxList<LessonUnitModel> lessons = <LessonUnitModel>[].obs;
  final RxBool isLoading = false.obs;

  UserProgressModel? get current => _progress.value;

  Future<void> bootstrap(User? user) async {
    if (user == null) return;
    isLoading.value = true;
    final cached = await _localService.loadCachedProgress(user.uid);
    if (cached != null) {
      _progress.value = cached.copyWith(
        displayName: user.displayName ?? cached.displayName,
        email: user.email ?? cached.email,
      );
    }
    final progress = await _firebaseService.loadProgress(user.uid);
    _progress.value = progress.copyWith(
      displayName: user.displayName ?? progress.displayName,
      email: user.email ?? progress.email,
    );
    await _localService.cacheProgress(_progress.value!);
    await _loadContent();
    isLoading.value = false;
  }

  Future<void> _loadContent() async {
    final allCharacters = await _firebaseService.fetchCharacters();
    characters.assignAll(allCharacters);
    final units = await _firebaseService.fetchUnits();
    lessons.assignAll(units);
  }

  Future<void> recordResult({
    required CharacterModel character,
    required String unitId,
    required int score,
    required bool success,
  }) async {
    final existing = current;
    if (existing == null) return;
    final updatedProgress = Map<String, Map<String, CharacterProgress>>.from(existing.progress);
    final unitProgress = Map<String, CharacterProgress>.from(updatedProgress[unitId] ?? {});
    unitProgress[character.character] = CharacterProgress(
      completed: success,
      score: score,
    );
    updatedProgress[unitId] = unitProgress;

    final xpDelta = success ? 10 : -2;
    final newXp = (existing.xp + xpDelta).clamp(0, 999999);
    final newStreak = success ? existing.streakDays + 1 : 0;

    final newModel = existing.copyWith(
      xp: newXp,
      streakDays: newStreak,
      progress: updatedProgress,
    );
    _progress.value = newModel;
    await _localService.cacheProgress(newModel);
    await _firebaseService.saveProgress(newModel);
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
    return entry?.completed == true && entry!.score >= 80;
  }

  Future<void> clear() async {
    _progress.value = null;
    await _localService.clear();
  }
}
