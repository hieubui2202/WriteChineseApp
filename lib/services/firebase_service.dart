import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/character_model.dart';
import '../models/lesson_unit_model.dart';
import '../models/user_progress_model.dart';

class FirebaseService {
  FirebaseService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<LessonUnitModel>> fetchUnits() async {
    try {
      final snapshot = await _firestore.collection('units').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map(
              (doc) => LessonUnitModel.fromMap(doc.data(), doc.id),
            )
            .toList();
      }
    } catch (error) {
      Get.log('Falling back to bundled units: $error');
    }
    final data = await _loadBundledData();
    final units = (data['units'] as List<dynamic>? ?? [])
        .map((e) => LessonUnitModel.fromMap(e as Map<String, dynamic>, e['id'].toString()))
        .toList();
    return units;
  }

  Future<List<CharacterModel>> fetchCharacters() async {
    try {
      final snapshot = await _firestore.collection('characters').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => CharacterModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (error) {
      Get.log('Falling back to bundled characters: $error');
    }
    final data = await _loadBundledData();
    final characters = (data['characters'] as List<dynamic>? ?? [])
        .map((e) => CharacterModel.fromMap(e as Map<String, dynamic>, e['character'].toString()))
        .toList();
    return characters;
  }

  Future<UserProgressModel> loadProgress(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProgressModel.fromMap(uid, doc.data()!);
      }
    } catch (error) {
      Get.log('Unable to load progress from Firestore: $error');
    }
    return UserProgressModel.empty(uid);
  }

  Future<void> saveProgress(UserProgressModel progress) async {
    try {
      await _firestore.collection('users').doc(progress.uid).set(progress.toMap(), SetOptions(merge: true));
    } catch (error) {
      Get.log('Failed to save progress to Firestore: $error');
    }
  }

  Future<Map<String, dynamic>> _loadBundledData() async {
    final raw = await rootBundle.loadString('assets/data/sample_characters.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
