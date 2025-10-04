import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hanzi_writer_app/app/modules/auth/auth_binding.dart';
import 'package:hanzi_writer_app/app/modules/auth/auth_screen.dart';
import 'package:hanzi_writer_app/app/modules/splash/splash_binding.dart';
import 'package:hanzi_writer_app/app/modules/splash/splash_screen.dart';
import 'app_routes.dart';

// Placeholder screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Lesson')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile')));
}

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
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.LESSON,
      page: () => const LessonScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
    ),
  ];
}
