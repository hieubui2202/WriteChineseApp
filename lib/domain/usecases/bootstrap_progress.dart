import '../entities/auth_user.dart';
import '../entities/character.dart';
import '../entities/lesson_unit.dart';
import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class BootstrapProgressResult {
  const BootstrapProgressResult({
    required this.progress,
    required this.characters,
    required this.units,
  });

  final UserProgress progress;
  final List<Character> characters;
  final List<LessonUnit> units;
}

class BootstrapProgress {
  const BootstrapProgress(this._repository);

  final ProgressRepository _repository;

  Future<BootstrapProgressResult> call(AuthUser user) async {
    final cached = await _repository.loadCachedProgress(user.uid);
    UserProgress? working;
    if (cached != null) {
      working = cached.copyWith(
        displayName: user.displayName ?? cached.displayName,
        email: user.email ?? cached.email,
      );
    }

    final remote = await _repository.loadProgress(user.uid);
    working = remote.copyWith(
      displayName: user.displayName ?? remote.displayName,
      email: user.email ?? remote.email,
    );

    final resolved = working;
    if (resolved == null) {
      throw StateError('Unable to resolve user progress for ${user.uid}');
    }

    await _repository.cacheProgress(resolved);

    final characters = await _repository.fetchCharacters();
    final units = await _repository.fetchUnits();

    return BootstrapProgressResult(
      progress: resolved,
      characters: characters,
      units: units,
    );
  }
}
