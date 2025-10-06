import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/lesson_unit.dart';
import '../controllers/practice_controller.dart';
import '../controllers/progress_controller.dart';
import '../controllers/splash_controller.dart';
import '../pages/auth/auth_page.dart';
import '../pages/home/home_page.dart';
import '../pages/practice/lesson_intro_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/review/review_page.dart';
import '../pages/splash/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewPage(),
    ),
    GetPage(
      name: AppRoutes.lesson,
      page: () => const _PracticeEntryPage(),
    ),
  ];
}

class _PracticeEntryPage extends StatelessWidget {
  const _PracticeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final unit = args?['unit'] as LessonUnit?;
    final character = args?['character'] as Character?;
    if (unit == null || character == null) {
      return const Scaffold(
        body: Center(
          child: Text('Không tìm thấy dữ liệu bài học.'),
        ),
      );
    }
    final progressController = Get.find<ProgressController>();
    final controller = Get.put(
      PracticeController(progressController: progressController),
      tag: unit?.id,
    );
    controller.startLesson(unit, character);
    return LessonIntroPage(controllerTag: unit.id);
  }
}
