import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress_model.dart';

class ProgressLocalService {
  static const _cacheKey = 'cached_user_progress';

  Future<void> cacheProgress(UserProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(progress.toMap()));
  }

  Future<UserProgressModel?> loadCachedProgress(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) {
      return null;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return UserProgressModel.fromMap(uid, data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
