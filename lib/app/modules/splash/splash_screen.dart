import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 240,
                child: Lottie.asset('assets/lottie/bear_wave.json'),
              ),
              const SizedBox(height: 24),
              Text(
                'Hanzi Writing Trainer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Đang đồng bộ dữ liệu và kiểm tra đăng nhập...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: controller.progress.value == 1 ? null : controller.progress.value,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFF00CFFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
