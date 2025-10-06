import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/character_model.dart';
import '../models/lesson_unit_model.dart';
import '../models/user_progress_model.dart';

class ProgressRemoteDataSource {
  ProgressRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<LessonUnitModel>> fetchUnits() async {
    final snapshot = await _firestore.collection('units').get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) => LessonUnitModel.fromMap(doc.data(), doc.id)).toList();
    }
    return _loadBundledUnits();
  }

  Future<List<CharacterModel>> fetchCharacters() async {
    final snapshot = await _firestore.collection('characters').get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) => CharacterModel.fromMap(doc.data(), doc.id)).toList();
    }
    return _loadBundledCharacters();
  }

  Future<UserProgressModel> loadProgress(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProgressModel.fromMap(uid, doc.data()!);
    }
    return UserProgressModel.empty(uid);
  }

  Future<void> saveProgress(UserProgressModel progress) {
    return _firestore.collection('users').doc(progress.uid).set(progress.toMap(), SetOptions(merge: true));
  }

  Future<List<LessonUnitModel>> _loadBundledUnits() async {
    final data = await _loadBundledData();
    return (data['units'] as List<dynamic>? ?? [])
        .map((unit) => LessonUnitModel.fromMap(unit as Map<String, dynamic>, unit['id'].toString()))
        .toList();
  }

  Future<List<CharacterModel>> _loadBundledCharacters() async {
    final data = await _loadBundledData();
    return (data['characters'] as List<dynamic>? ?? [])
        .map((character) => CharacterModel.fromMap(character as Map<String, dynamic>, character['character'].toString()))
        .toList();
  }

  Future<Map<String, dynamic>> _loadBundledData() async {
    final raw = await rootBundle.loadString('assets/data/sample_characters.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
