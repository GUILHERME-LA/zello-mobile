import 'package:flutter_test/flutter_test.dart';
import 'package:zello_admin_app/main.dart';

void main() {
  testWidgets('AdminApp renders without errors', (tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.text('Zello Saúde - Admin'), findsOneWidget);
  });
}
