import 'character_progress.dart';

class UserProgress {
  const UserProgress({
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

  UserProgress copyWith({
    String? displayName,
    String? email,
    int? streakDays,
    int? xp,
    Map<String, Map<String, CharacterProgress>>? progress,
  }) {
    return UserProgress(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      streakDays: streakDays ?? this.streakDays,
      xp: xp ?? this.xp,
      progress: progress ?? this.progress,
    );
  }
}
