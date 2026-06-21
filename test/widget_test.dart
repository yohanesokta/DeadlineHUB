import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/main.dart';

void main() {
  testWidgets('DeadlineAIApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeadlineAIApp()));
    expect(find.byType(DeadlineAIApp), findsOneWidget);
  });
}
