import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../ui/widgets/primary_button.dart';
import 'auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121418), Color(0xFF090B0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 220,
                  child: Lottie.asset('assets/lottie/bear_wave.json'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Hanzi Writing Trainer',
                  style: Get.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Luyện viết chữ Hán kiểu Duolingo với âm thanh, stroke animation và bảng thành tích của bạn.',
                  style: Get.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Đăng nhập với Google',
                  icon: Icons.g_mobiledata,
                  onPressed: controller.signInWithGoogle,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Học thử ngay (Không cần tài khoản)',
                  icon: Icons.bolt,
                  onPressed: controller.signInAnonymously,
                  variant: ButtonVariant.secondary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Dữ liệu tiến độ sẽ được đồng bộ an toàn với Firebase và vẫn học được khi offline.',
                  style: Get.textTheme.bodySmall?.copyWith(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
