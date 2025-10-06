import 'package:get/get.dart';

import '../models/user_progress_model.dart';
import '../services/firebase_service.dart';
import '../services/progress_local_service.dart';
import 'progress_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this.progressController, {FirebaseService? firebaseService, ProgressLocalService? localService})
      : _firebaseService = firebaseService ?? FirebaseService(),
        _localService = localService ?? ProgressLocalService();

  final ProgressController progressController;
  final FirebaseService _firebaseService;
  final ProgressLocalService _localService;

  UserProgressModel? get progress => progressController.current;

  Future<void> syncNow() async {
    final progress = progressController.current;
    if (progress == null) return;
    await _firebaseService.saveProgress(progress);
    await _localService.cacheProgress(progress);
  }
}
