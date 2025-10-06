import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class SyncProgress {
  const SyncProgress(this._repository);

  final ProgressRepository _repository;

  Future<void> call(UserProgress progress) async {
    await _repository.saveProgress(progress);
    await _repository.cacheProgress(progress);
  }
}
