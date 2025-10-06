import 'package:get/get.dart';

import '../../domain/entities/user_progress.dart';
import '../../domain/usecases/sync_progress.dart';
import 'progress_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this.progressController, {required SyncProgress syncProgress})
      : _syncProgress = syncProgress;

  final ProgressController progressController;
  final SyncProgress _syncProgress;

  UserProgress? get progress => progressController.current;

  Future<void> syncNow() async {
    final snapshot = progressController.current;
    if (snapshot == null) return;
    await _syncProgress(snapshot);
  }
}
