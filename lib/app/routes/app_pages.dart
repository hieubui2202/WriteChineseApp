import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/auth/auth_binding.dart';
import '../modules/auth/auth_screen.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_screen.dart';
import '../../ui/home/home_page.dart';
import '../../ui/practice/lesson_intro_page.dart';
import '../../ui/profile/profile_page.dart';
import '../../ui/review/review_page.dart';
import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../models/character_model.dart';
import '../../models/lesson_unit_model.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.REVIEW,
      page: () => const ReviewPage(),
    ),
    GetPage(
      name: Routes.LESSON,
      page: () => const _PracticeEntryPage(),
    ),
  ];
}

class _PracticeEntryPage extends StatelessWidget {
  const _PracticeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final unit = args?['unit'] as LessonUnitModel?;
    final character = args?['character'] as CharacterModel?;
    final progressController = Get.find<ProgressController>();
    final controller = Get.put(
      PracticeController(progressController: progressController),
      tag: unit?.id,
    );
    if (unit != null && character != null) {
      controller.startLesson(unit, character);
    }
    return LessonIntroPage(controllerTag: unit?.id ?? '');
  }
}
