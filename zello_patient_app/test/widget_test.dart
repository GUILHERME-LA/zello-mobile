import 'package:flutter_test/flutter_test.dart';
import 'package:zello_patient_app/main.dart';

void main() {
  testWidgets('PatientApp renders without errors', (tester) async {
    await tester.pumpWidget(const PatientApp());
    expect(find.text('Zello Saúde - Paciente'), findsOneWidget);
  });
}
