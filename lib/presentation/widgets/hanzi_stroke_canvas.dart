import 'dart:math' as math;

import 'package:flutter/material.dart';

class HanziStrokeCanvas extends StatefulWidget {
  const HanziStrokeCanvas({
    super.key,
    required this.strokePaths,
    required this.designWidth,
    required this.designHeight,
    required this.onCompleted,
    this.strokeColor = const Color(0xFF00CFFF),
  });

  final List<String> strokePaths;
  final double designWidth;
  final double designHeight;
  final ValueChanged<bool> onCompleted;
  final Color strokeColor;

  @override
  State<HanziStrokeCanvas> createState() => HanziStrokeCanvasState();
}

class HanziStrokeCanvasState extends State<HanziStrokeCanvas>
    with SingleTickerProviderStateMixin {
  late final List<Path> _targetStrokes =
      widget.strokePaths.map(_parsePath).toList(growable: false);
  final List<List<Offset>> _userStrokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  late final AnimationController _pulseController;
  bool _didComplete = false;
  int _currentStrokeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
          ..repeat(reverse: true);
    if (widget.strokePaths.isEmpty) {
      _didComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCompleted(true);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HanziStrokePainter(
                    targetStrokes: _targetStrokes,
                    userStrokes: _userStrokes,
                    designWidth: widget.designWidth,
                    designHeight: widget.designHeight,
                    currentStrokeIndex: _currentStrokeIndex,
                    pulseValue: _pulseController.value,
                    strokeColor: widget.strokeColor,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void resetCanvas() {
    if (!mounted) return;
    setState(() {
      _userStrokes.clear();
      _currentStroke = null;
      _currentStrokeIndex = 0;
      _didComplete = false;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    if (_didComplete) return;
    setState(() {
      final stroke = <Offset>[details.localPosition];
      _userStrokes.add(stroke);
      _currentStroke = stroke;
      final maxIndex = math.max(widget.strokePaths.length - 1, 0);
      final currentIndex = math.max(_userStrokes.length - 1, 0);
      _currentStrokeIndex = math.min(currentIndex, maxIndex);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_didComplete) return;
    setState(() {
      _currentStroke?.add(details.localPosition);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_didComplete) return;
    setState(() {
      if (_currentStroke != null && _currentStroke!.length < 2) {
        _userStrokes.remove(_currentStroke);
      }
      _currentStroke = null;
      if (_userStrokes.isNotEmpty) {
        final maxIndex = math.max(widget.strokePaths.length - 1, 0);
        _currentStrokeIndex =
            math.min(_userStrokes.length, maxIndex);
        if (widget.strokePaths.isNotEmpty &&
            _userStrokes.length >= widget.strokePaths.length) {
          _didComplete = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCompleted(true);
          });
        }
      }
    });
  }

  Path _parsePath(String data) {
    final cleaned = data.replaceAll(',', ' ').trim();
    final tokens = cleaned.split(RegExp(r'\s+'));
    final path = Path();
    String command = 'M';
    int index = 0;
    while (index < tokens.length) {
      final token = tokens[index];
      if (token == 'M' || token == 'L') {
        command = token;
        index++;
        continue;
      }
      if (index + 1 >= tokens.length) {
        break;
      }
      final double? x = double.tryParse(tokens[index]);
      final double? y = double.tryParse(tokens[index + 1]);
      if (x != null && y != null) {
        if (command == 'M') {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      index += 2;
    }
    return path;
  }
}

class _HanziStrokePainter extends CustomPainter {
  _HanziStrokePainter({
    required this.targetStrokes,
    required this.userStrokes,
    required this.designWidth,
    required this.designHeight,
    required this.currentStrokeIndex,
    required this.pulseValue,
    required this.strokeColor,
  });

  final List<Path> targetStrokes;
  final List<List<Offset>> userStrokes;
  final double designWidth;
  final double designHeight;
  final int currentStrokeIndex;
  final double pulseValue;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / designWidth,
      size.height / designHeight,
    );
    final dx = (size.width - designWidth * scale) / 2;
    final dy = (size.height - designHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final ghostPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6;

    final completedPaint = Paint()
      ..color = strokeColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8;

    final highlightPaint = Paint()
      ..color = strokeColor.withOpacity(0.4 + 0.6 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10;

    for (int i = 0; i < targetStrokes.length; i++) {
      final path = targetStrokes[i];
      if (i < currentStrokeIndex) {
        canvas.drawPath(path, completedPaint);
      } else if (i == currentStrokeIndex) {
        canvas.drawPath(path, highlightPaint);
      } else {
        canvas.drawPath(path, ghostPaint);
      }
    }

    canvas.restore();

    final userPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8;

    for (final stroke in userStrokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, userPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HanziStrokePainter oldDelegate) {
    return true;
  }
}
