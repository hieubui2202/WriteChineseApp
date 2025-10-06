import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/bootstrap_progress.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../routes/app_routes.dart';
import 'progress_controller.dart';

class AuthController extends GetxController {
  AuthController({
    required WatchAuthState watchAuthState,
    required SignInWithGoogle signInWithGoogle,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required BootstrapProgress bootstrapProgress,
    ProgressController? progressController,
  })  : _watchAuthState = watchAuthState,
        _signInWithGoogle = signInWithGoogle,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _bootstrapProgress = bootstrapProgress,
        _progressController = progressController;

  final WatchAuthState _watchAuthState;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final BootstrapProgress _bootstrapProgress;
  ProgressController? _progressController;

  bool _initialized = false;
  StreamSubscription<AuthUser?>? _subscription;

  @override
  void onReady() {
    super.onReady();
    _subscription = _watchAuthState().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(AuthUser? user) async {
    _progressController ??= Get.find<ProgressController>();
    if (user == null) {
      if (!_initialized) {
        _initialized = true;
      }
      Get.offAllNamed(AppRoutes.auth);
      return;
    }

    try {
      _progressController?.isLoading.value = true;
      final result = await _bootstrapProgress(user);
      _progressController?.setBootstrap(result);
      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      Get.snackbar('Failed to load progress', error.toString());
    } finally {
      _initialized = true;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _signInWithGoogle();
    } catch (error) {
      Get.snackbar('Sign-in failed', error.toString());
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _signInAnonymously();
    } catch (error) {
      Get.snackbar('Unable to start trial', error.toString());
    }
  }

  Future<void> signOut() async {
    await _signOut();
    await _progressController?.clearProgress();
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
