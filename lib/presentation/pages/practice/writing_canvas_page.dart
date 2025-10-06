import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/practice_controller.dart';
import '../../widgets/hanzi_stroke_canvas.dart';
import 'missing_stroke_page.dart';

class WritingCanvasPage extends StatefulWidget {
  const WritingCanvasPage({super.key, required this.controllerTag});

  final String controllerTag;

  @override
  State<WritingCanvasPage> createState() => _WritingCanvasPageState();
}

class _WritingCanvasPageState extends State<WritingCanvasPage> {
  late PracticeController controller;
  bool _hasNavigated = false;
  late final GlobalKey<HanziStrokeCanvasState> _canvasKey;

  @override
  void initState() {
    super.initState();
    controller = Get.find(tag: widget.controllerTag);
    _canvasKey = GlobalKey<HanziStrokeCanvasState>();
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
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          color: const Color(0xFF1A1D24),
                          child: HanziStrokeCanvas(
                            key: _canvasKey,
                            strokePaths: character.strokeData.paths,
                            designWidth: character.strokeData.width,
                            designHeight: character.strokeData.height,
                            onCompleted: _handleCompletion,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vẽ theo nét gợi ý. Hoàn thành đủ số nét để tiếp tục.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _canvasKey.currentState?.resetCanvas(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Làm lại'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => _handleCompletion(false),
                          child: const Text('Bỏ qua'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Expanded(child: Center(child: Text('Không có dữ liệu chữ.'))),
          ],
        ),
      ),
    );
  }

  void _handleCompletion(bool success) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    controller.completeWriting(success: success);
    Get.off(() => MissingStrokePage(controllerTag: widget.controllerTag));
  }
}
