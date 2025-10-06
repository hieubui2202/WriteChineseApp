import '../../domain/entities/character_progress.dart';
import '../../domain/entities/user_progress.dart';

class UserProgressModel extends UserProgress {
  const UserProgressModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.streakDays,
    required super.xp,
    required super.progress,
  });

  factory UserProgressModel.empty(String uid) {
    return UserProgressModel(
      uid: uid,
      displayName: '',
      email: '',
      streakDays: 0,
      xp: 0,
      progress: const {},
    );
  }

  factory UserProgressModel.fromMap(String uid, Map<String, dynamic> data) {
    final rawProgress = data['progress'] as Map<String, dynamic>? ?? {};
    final progress = <String, Map<String, CharacterProgress>>{};
    for (final entry in rawProgress.entries) {
      final unitProgress = <String, CharacterProgress>{};
      final unitData = entry.value as Map<String, dynamic>? ?? {};
      for (final characterEntry in unitData.entries) {
        unitProgress[characterEntry.key] = CharacterProgress(
          completed: (characterEntry.value as Map<String, dynamic>? ?? {})['completed'] as bool? ?? false,
          score: ((characterEntry.value as Map<String, dynamic>? ?? {})['score'] as num?)?.toInt() ?? 0,
        );
      }
      progress[entry.key] = unitProgress;
    }
    return UserProgressModel(
      uid: uid,
      displayName: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      progress: progress,
    );
  }

  Map<String, dynamic> toMap() {
    final progressMap = <String, dynamic>{};
    for (final entry in progress.entries) {
      progressMap[entry.key] = {
        for (final inner in entry.value.entries)
          inner.key: {
            'completed': inner.value.completed,
            'score': inner.value.score,
          },
      };
    }
    return {
      'name': displayName,
      'email': email,
      'streakDays': streakDays,
      'xp': xp,
      'progress': progressMap,
    };
  }
}
