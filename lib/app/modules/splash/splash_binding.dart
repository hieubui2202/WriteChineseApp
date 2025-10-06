import 'package:get/get.dart';

import '../../../controllers/progress_controller.dart';
import '../auth/auth_controller.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProgressController>(ProgressController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
