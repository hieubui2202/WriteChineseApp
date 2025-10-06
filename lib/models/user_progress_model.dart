class CharacterProgress {
  const CharacterProgress({
    required this.completed,
    required this.score,
  });

  final bool completed;
  final int score;

  factory CharacterProgress.fromMap(Map<String, dynamic> data) {
    return CharacterProgress(
      completed: data['completed'] as bool? ?? false,
      score: (data['score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'completed': completed,
        'score': score,
      };
}

class UserProgressModel {
  const UserProgressModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.streakDays,
    required this.xp,
    required this.progress,
  });

  final String uid;
  final String displayName;
  final String email;
  final int streakDays;
  final int xp;
  final Map<String, Map<String, CharacterProgress>> progress;

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
        unitProgress[characterEntry.key] = CharacterProgress.fromMap(
          characterEntry.value as Map<String, dynamic>? ?? {},
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
          inner.key: inner.value.toMap(),
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

  UserProgressModel copyWith({
    String? displayName,
    String? email,
    int? streakDays,
    int? xp,
    Map<String, Map<String, CharacterProgress>>? progress,
  }) {
    return UserProgressModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      streakDays: streakDays ?? this.streakDays,
      xp: xp ?? this.xp,
      progress: progress ?? this.progress,
    );
  }
}
