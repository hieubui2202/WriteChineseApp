import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/review_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../services/audio_service.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late ReviewController controller;
  late AudioService audioService;

  @override
  void initState() {
    super.initState();
    final progressController = Get.find<ProgressController>();
    controller = Get.put(ReviewController(progressController));
    audioService = AudioService();
  }

  @override
  void dispose() {
    audioService.dispose();
    Get.delete<ReviewController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn tập chữ đã học'),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        final mastered = controller.masteredCharacters;
        if (mastered.isEmpty) {
          return const Center(child: Text('Hãy hoàn thành một bài học để bắt đầu ôn tập!'));
        }
        final character = mastered[controller.index.value];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                character.character,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 120),
              ),
              const SizedBox(height: 16),
              Text(character.pinyin, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(character.meaning, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.previous,
                    icon: const Icon(Icons.chevron_left, size: 32),
                  ),
                  IconButton(
                    onPressed: () => audioService.play(character.ttsUrl),
                    icon: const Icon(Icons.volume_up, size: 32),
                  ),
                  IconButton(
                    onPressed: controller.next,
                    icon: const Icon(Icons.chevron_right, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => audioService.play(character.ttsUrl),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00CFFF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Nghe lại phát âm'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
