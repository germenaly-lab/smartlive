import 'package:flutter_test/flutter_test.dart';
import 'package:smartlive/main.dart';

void main() {
  testWidgets('Smart Life app Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartLifeApp());
    expect(find.byType(SmartLifeApp), findsOneWidget);
  });
}
