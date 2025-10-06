import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../routes/app_routes.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.controllerTag});

  final String controllerTag;

  PracticeController get controller => Get.find(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final character = controller.currentCharacter.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoàn thành bài học'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 200, child: Lottie.asset('assets/lottie/success.json', repeat: false)),
            Text(
              controller.isCorrect.value ? 'Tuyệt vời!' : 'Cần luyện thêm!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Điểm: ${controller.score.value}/100',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF00CFFF)),
            ),
            const SizedBox(height: 24),
            Text(
              'XP hiện tại: ${progressController.current?.xp ?? 0}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (character != null)
              Text(
                '${character.character} · ${character.pinyin} · ${character.meaning}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.delete<PracticeController>(tag: controllerTag);
                Get.offAllNamed(AppRoutes.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Tiếp tục chữ tiếp theo'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
