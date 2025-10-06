import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _animateProgress();
  }

  Future<void> _animateProgress() async {
    for (var i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 40));
      progress.value = i / 100;
    }
  }
}
