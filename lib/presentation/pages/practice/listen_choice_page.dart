import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import 'meaning_choice_page.dart';

class ListenChoicePage extends StatelessWidget {
  const ListenChoicePage({super.key, required this.controllerTag});

  final String controllerTag;

  PracticeController get controller => Get.find(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bước 2/5: Nghe & chọn âm'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Nghe phát âm và chọn Pinyin đúng',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.playAudio,
              icon: const Icon(Icons.volume_up),
              label: const Text('Phát lại audio'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.listenOptions.length,
                  itemBuilder: (context, index) {
                    final option = controller.listenOptions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          controller.checkListenAnswer(option);
                          Get.off(() => MeaningChoicePage(controllerTag: controllerTag));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF1F2A37),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFF00CFFF)),
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
