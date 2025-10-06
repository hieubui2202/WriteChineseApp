import '../repositories/progress_repository.dart';

class ClearProgressCache {
  const ClearProgressCache(this._repository);

  final ProgressRepository _repository;

  Future<void> call() => _repository.clearCache();
}
