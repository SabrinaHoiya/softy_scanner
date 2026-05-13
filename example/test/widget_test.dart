import 'package:flutter_test/flutter_test.dart';
import 'package:softy_scanner_example/main.dart';

void main() {
  testWidgets('Home page shows scan button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Open Scanner'), findsOneWidget);
  });
}
