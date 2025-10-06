import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import 'writing_canvas_page.dart';

class MeaningChoicePage extends StatelessWidget {
  const MeaningChoicePage({super.key, required this.controllerTag});

  final String controllerTag;

  PracticeController get controller => Get.find(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bước 3/5: Chọn nghĩa'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Chữ này có nghĩa là gì?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Obx(() {
              final character = controller.currentCharacter.value;
              return Text(
                character?.character ?? '',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 96),
              );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.meaningOptions.length,
                  itemBuilder: (context, index) {
                    final option = controller.meaningOptions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          controller.checkMeaningAnswer(option);
                          Get.off(() => WritingCanvasPage(controllerTag: controllerTag));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          backgroundColor: const Color(0xFF1F2A37),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFFFD166)),
                          ),
                        ),
                        child: Text(option, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
