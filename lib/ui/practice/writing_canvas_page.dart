import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanzi_writer/hanzi_writer.dart';

import '../../controllers/practice_controller.dart';
import 'missing_stroke_page.dart';

class WritingCanvasPage extends StatefulWidget {
  const WritingCanvasPage({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  State<WritingCanvasPage> createState() => _WritingCanvasPageState();
}

class _WritingCanvasPageState extends State<WritingCanvasPage> {
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
        title: const Text('Bước 4/5: Luyện viết'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Vẽ theo thứ tự nét hiển thị', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (character != null)
              Expanded(
                child: HanziWriter(
                  character: character.character,
                  width: 320,
                  height: 320,
                  showCharacter: true,
                  onCorrectStroke: (_) {
                    setState(() => success = true);
                  },
                  onComplete: () {
                    controller.completeWriting(success: success);
                    Get.off(() => MissingStrokePage(controllerTag: widget.controllerTag));
                  },
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
