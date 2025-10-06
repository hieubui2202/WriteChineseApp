import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/practice_controller.dart';
import 'result_page.dart';

class MissingStrokePage extends StatefulWidget {
  const MissingStrokePage({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  State<MissingStrokePage> createState() => _MissingStrokePageState();
}

class _MissingStrokePageState extends State<MissingStrokePage> {
  late PracticeController controller;
  bool success = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find(tag: widget.controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    final character = controller.currentCharacter.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bước 5/5: Điền nét thiếu'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Vẽ thêm nét còn thiếu để hoàn thành chữ', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (character != null)
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onPanEnd: (_) {
                      if (success) return;
                      setState(() => success = true);
                      controller.completeMissingStroke(success: true);
                      Get.off(() => ResultPage(controllerTag: widget.controllerTag));
                    },
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1F2A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF00CFFF).withOpacity(0.6), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            character.character,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(color: Colors.white10, fontSize: 120),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: success
                                ? Lottie.asset('assets/lottie/correct.json', repeat: false, key: const ValueKey('success'))
                                : const Icon(Icons.brush, size: 48, color: Color(0xFF00CFFF), key: ValueKey('brush')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const Expanded(child: Center(child: Text('Không có dữ liệu chữ.'))),
          ],
        ),
      ),
    );
  }
}
