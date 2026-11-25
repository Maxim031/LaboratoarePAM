import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lab4/app.dart';
import 'package:lab4/presentation/screens/details_screen.dart';
import 'package:lab4/presentation/widgets/common.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Roboto')
          ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/roboto-bold.ttf')))
        .load();
  });
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  testWidgets('Loading, offline error and retry render', (tester) async {
    final pending = Completer<http.Response>();
    var count = 0;
    await tester.pumpWidget(
      DoctorApp(
        repository: fixtureRepository(
          handler: (_) => count++ == 0
              ? pending.future
              : Future.value(http.Response(fixture('feed'), 200)),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(http.ClientException('offline'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Check your internet connection'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Jonathan'), findsOneWidget);
  });
  for (final size in [const Size(320, 640), const Size(412, 892)]) {
    testWidgets(
      'HTTP detail failure recovers, selected doctor and favorites at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var detailCalls = 0;
        await tester.pumpWidget(
          DoctorApp(
            repository: fixtureRepository(
              handler: (request) async {
                if (request.url.path.endsWith('/details')) {
                  return detailCalls++ == 0
                      ? http.Response('', 503)
                      : http.Response(fixture('details'), 200);
                }
                return http.Response(fixture('feed'), 200);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(detailCalls, 0);
        await tester.enterText(find.byType(TextField), 'nothing');
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Reset filters'),
          200,
          scrollable: vertical,
        );
        await tester.ensureVisible(find.text('Reset filters'));
        await tester.pumpAndSettle();
        expect(find.text('No doctors found'), findsOneWidget);
        await tester.tap(find.text('Reset filters'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Dr. Sonja Litel'),
          150,
          scrollable: vertical,
        );
        await tester.ensureVisible(find.text('Dr. Sonja Litel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dr. Sonja Litel'));
        await tester.pumpAndSettle();
        expect(find.text('Could not load details'), findsOneWidget);
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.text('Dr. Sonja Litel'), findsOneWidget);
        expect(detailCalls, 2);
        await tester.tap(find.byTooltip('Toggle favorite'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Mon 5'),
          200,
          scrollable: vertical,
        );
        await tester.tap(find.text('Mon 5'));
        await tester.scrollUntilVisible(
          find.text('Book an Appointment'),
          200,
          scrollable: vertical,
        );
        await tester.tap(find.text('Book an Appointment'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('booking-confirmation')),
          findsOneWidget,
        );
        Navigator.of(tester.element(find.byType(DetailsScreen))).pop();
        await tester.pumpAndSettle();
        expect(
          tester.widget<DoctorTile>(find.byType(DoctorTile).last).favorite,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
