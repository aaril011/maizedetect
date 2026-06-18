import 'package:flutter_test/flutter_test.dart';

import 'package:maizedetect/main.dart';

void main() {
  testWidgets('MaizeDetect home and tabs render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaizeDetectApp());
    await tester.pump();

    expect(find.text('Farm Health Summary'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Center the affected leaf in the frame'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Scan History'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Recommended Action Plan'), findsOneWidget);
  });
}
