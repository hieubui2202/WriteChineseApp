import 'package:get/get.dart';
import 'package:hanzi_writer_app/app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement authentication check here
    // For now, we'll just navigate to the auth screen
    Get.offAllNamed(Routes.AUTH);
  }
}
