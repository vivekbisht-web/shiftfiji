import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftfiji/main.dart';
import 'package:shiftfiji/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('Shift Fiji App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShiftFijiApp());
    await tester.pumpAndSettle();

    expect(find.text('SHIFT FIJI'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
