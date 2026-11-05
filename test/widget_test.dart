import 'package:flutter_test/flutter_test.dart';
import 'package:shopflow/main.dart';

void main() {
  testWidgets('ShopFlow app launches successfully', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const ShopFlowApp());

    expect(find.text('ShopFlow'), findsOneWidget);
  });
}