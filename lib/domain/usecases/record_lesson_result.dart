import '../entities/character.dart';
import '../entities/character_progress.dart';
import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class RecordLessonResultParams {
  const RecordLessonResultParams({
    required this.character,
    required this.unitId,
    required this.score,
    required this.success,
  });

  final Character character;
  final String unitId;
  final int score;
  final bool success;
}

class RecordLessonResult {
  const RecordLessonResult(this._repository);

  final ProgressRepository _repository;

  Future<UserProgress> call(UserProgress current, RecordLessonResultParams params) async {
    final updatedProgress = Map<String, Map<String, CharacterProgress>>.from(current.progress);
    final unitProgress = Map<String, CharacterProgress>.from(updatedProgress[params.unitId] ?? {});
    unitProgress[params.character.character] = CharacterProgress(
      completed: params.success,
      score: params.score,
    );
    updatedProgress[params.unitId] = unitProgress;

    final xpDelta = params.success ? 10 : -2;
    final newXp = (current.xp + xpDelta).clamp(0, 999999);
    final newStreak = params.success ? current.streakDays + 1 : 0;

    final updated = current.copyWith(
      xp: newXp,
      streakDays: newStreak,
      progress: updatedProgress,
    );

    await _repository.cacheProgress(updated);
    await _repository.saveProgress(updated);

    return updated;
  }
}
