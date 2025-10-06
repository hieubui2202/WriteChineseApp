import '../entities/character.dart';
import '../entities/lesson_unit.dart';
import '../entities/user_progress.dart';

abstract class ProgressRepository {
  Future<UserProgress> loadProgress(String uid);
  Future<void> saveProgress(UserProgress progress);
  Future<List<Character>> fetchCharacters();
  Future<List<LessonUnit>> fetchUnits();
  Future<UserProgress?> loadCachedProgress(String uid);
  Future<void> cacheProgress(UserProgress progress);
  Future<void> clearCache();
}
