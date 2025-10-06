import '../../domain/entities/character.dart';
import '../../domain/entities/lesson_unit.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';
import '../datasources/progress_remote_data_source.dart';
import '../models/user_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    ProgressRemoteDataSource? remoteDataSource,
    ProgressLocalDataSource? localDataSource,
  })  : _remote = remoteDataSource ?? ProgressRemoteDataSource(),
        _local = localDataSource ?? ProgressLocalDataSource();

  final ProgressRemoteDataSource _remote;
  final ProgressLocalDataSource _local;

  @override
  Future<void> cacheProgress(UserProgress progress) {
    return _local.cacheProgress(_toModel(progress));
  }

  @override
  Future<void> clearCache() => _local.clear();

  @override
  Future<List<Character>> fetchCharacters() => _remote.fetchCharacters();

  @override
  Future<List<LessonUnit>> fetchUnits() => _remote.fetchUnits();

  @override
  Future<UserProgress?> loadCachedProgress(String uid) => _local.loadCachedProgress(uid);

  @override
  Future<UserProgress> loadProgress(String uid) => _remote.loadProgress(uid);

  @override
  Future<void> saveProgress(UserProgress progress) {
    return _remote.saveProgress(_toModel(progress));
  }

  UserProgressModel _toModel(UserProgress progress) {
    if (progress is UserProgressModel) {
      return progress;
    }
    return UserProgressModel(
      uid: progress.uid,
      displayName: progress.displayName,
      email: progress.email,
      streakDays: progress.streakDays,
      xp: progress.xp,
      progress: progress.progress,
    );
  }
}
