import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab3/main.dart';
import 'package:lab3/data/catalog_repository.dart';
import 'package:lab3/screens/details_screen.dart';
import 'package:lab3/widgets/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixture = File('assets/data/lab_v2.json').readAsStringSync();
  setUpAll(() async {
    await (FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf')))
        .load();
  });

  testWidgets('Loading, error and retry are visible', (tester) async {
    final pending = Completer<String>();
    var count = 0;
    await tester.pumpWidget(
      DoctorApp(
        repository: CatalogRepository(
          loadText: () => count++ == 0 ? pending.future : Future.value(fixture),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(const FormatException('bad asset'));
    await tester.pumpAndSettle();
    expect(find.text('Something went wrong'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Jonathan'), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(412, 892)]) {
    testWidgets('Search, empty state, details and favorites work at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        DoctorApp(repository: CatalogRepository(loadText: () async => fixture)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'nobody');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('No doctors found'),
        250,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      expect(find.text('No doctors found'), findsOneWidget);
      await tester.ensureVisible(find.text('Reset filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset filters'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Dr. Sonja Litel'),
        150,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      await tester.tap(find.text('Dr. Sonja Litel'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailsScreen), findsOneWidget);
      expect(find.text('Dr. Sonja Litel'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Toggle favorite'));
      await tester.scrollUntilVisible(
        find.text('Mon 5'),
        200,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      await tester.tap(find.text('Mon 5'));
      await tester.scrollUntilVisible(find.text('Book an Appointment'), 200);
      await tester.tap(find.text('Book an Appointment'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('booking-confirmation')),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      final tile = tester.widget<DoctorTile>(find.byType(DoctorTile).last);
      expect(tile.favorite, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
