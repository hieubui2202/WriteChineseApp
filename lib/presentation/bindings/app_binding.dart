import 'package:get/get.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/bootstrap_progress.dart';
import '../../domain/usecases/clear_progress_cache.dart';
import '../../domain/usecases/record_lesson_result.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sync_progress.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../controllers/auth_controller.dart';
import '../controllers/progress_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);
    Get.lazyPut<ProgressRepository>(() => ProgressRepositoryImpl(), fenix: true);

    Get.lazyPut(() => WatchAuthState(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SignInWithGoogle(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SignInAnonymously(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SignOut(Get.find<AuthRepository>()), fenix: true);

    Get.lazyPut(() => BootstrapProgress(Get.find<ProgressRepository>()), fenix: true);
    Get.lazyPut(() => RecordLessonResult(Get.find<ProgressRepository>()), fenix: true);
    Get.lazyPut(() => ClearProgressCache(Get.find<ProgressRepository>()), fenix: true);
    Get.lazyPut(() => SyncProgress(Get.find<ProgressRepository>()), fenix: true);

    Get.put(
      ProgressController(
        recordLessonResult: Get.find<RecordLessonResult>(),
        clearProgressCache: Get.find<ClearProgressCache>(),
      ),
      permanent: true,
    );

    Get.put(
      AuthController(
        watchAuthState: Get.find<WatchAuthState>(),
        signInWithGoogle: Get.find<SignInWithGoogle>(),
        signInAnonymously: Get.find<SignInAnonymously>(),
        signOut: Get.find<SignOut>(),
        bootstrapProgress: Get.find<BootstrapProgress>(),
        progressController: Get.find<ProgressController>(),
      ),
      permanent: true,
    );
  }
}
