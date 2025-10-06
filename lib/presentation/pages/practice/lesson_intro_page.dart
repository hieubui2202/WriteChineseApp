import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import 'listen_choice_page.dart';

class LessonIntroPage extends StatelessWidget {
  const LessonIntroPage({super.key, required this.controllerTag});

  final String controllerTag;

  PracticeController get controller => Get.find(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final character = controller.currentCharacter.value;
    if (character == null) {
      return const Scaffold(body: Center(child: Text('Không có dữ liệu bài học.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bước 1/5: Giới thiệu'),
        backgroundColor: Colors.transparent,
      ),
      body: _buildContent(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.goToNextStep();
          Get.off(() => ListenChoicePage(controllerTag: controllerTag));
        },
        label: const Text('Bắt đầu'),
        icon: const Icon(Icons.play_arrow),
        backgroundColor: const Color(0xFF00CFFF),
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final character = controller.currentCharacter.value;
    if (character == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            character.character,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 100),
          ),
          const SizedBox(height: 12),
          Text(character.pinyin, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(character.meaning, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: controller.playAudio,
            icon: const Icon(Icons.volume_up),
            label: const Text('Nghe phát âm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CFFF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quan sát chữ, đọc to theo âm thanh và sẵn sàng luyện tập giống Duolingo!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
