import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf'));
    await loader.load();
  });
  for (final size in [
    const Size(329, 712),
    const Size(377, 817),
    const Size(360, 640),
  ]) {
    testWidgets('Screens fit and appointment selection works at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const DoctorApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tester.tap(find.text('Appointment'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Mon 5'));
      await tester.tap(find.text('10.00 AM'));
      await tester.ensureVisible(find.text('Book an Appointment'));
      await tester.tap(find.text('Book an Appointment'));
      await tester.pumpAndSettle();
      expect(find.text('Appointment booked: Mon 5, 10.00 AM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
