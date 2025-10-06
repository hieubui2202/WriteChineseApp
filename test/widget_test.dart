import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hanzi_trainer/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HanziTrainerApp());
    await tester.pump();
    expect(find.text('Hanzi Writing Trainer'), findsOneWidget);
  });
}
