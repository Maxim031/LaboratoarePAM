import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4/data/datasources/doctors_remote_data_source.dart';
import 'package:lab4/data/models/api_dtos.dart';
import 'package:lab4/data/repositories/http_doctors_repository.dart';
import 'package:lab4/domain/failures/app_failure.dart';

import 'helpers.dart';

void main() {
  test(
    'Feed and details issue separate GET requests to the v2 endpoints',
    () async {
      final requests = <http.Request>[];
      final repo = fixtureRepository(
        handler: (r) async {
          requests.add(r);
          return http.Response(
            fixture(r.url.path.endsWith('/details') ? 'details' : 'feed'),
            200,
          );
        },
      );
      final feed = await repo.getFeed();
      expect(feed.doctors.length, 2);
      expect(requests.length, 1);
      expect(feed.appointmentDoctor.name, 'Dr. Richar Kandowen');
      final details = await repo.getAppointmentDetails();
      expect(details.amount, 120);
      expect(requests.map((r) => r.url.toString()), [
        'https://test-api-jlbn.onrender.com/lab2026/v2/feed',
        'https://test-api-jlbn.onrender.com/lab2026/v2/feed/details',
      ]);
      for (final request in requests) {
        expect(request.method, 'GET');
        expect(
          request.headers['Accept'] ?? request.headers['accept'],
          'application/json',
        );
      }
    },
  );

  test('Feed DTO serializes back to the original API JSON', () {
    final input = fixtureJson('feed');
    final dto = FeedDto.fromJson(input);
    expect(jsonDecode(jsonEncode(dto.toJson())), input);
    expect(
      FeedDto.fromJson(dto.toJson()).toEntity().doctors[1].id,
      'doctor-002',
    );
  });
  test('Details DTO serializes nested slots, actions and payment', () {
    final input = fixtureJson('details');
    final dto = AppointmentDto.fromJson(input);
    expect(jsonDecode(jsonEncode(dto.toJson())), input);
    expect(
      AppointmentDto.fromJson(dto.toJson()).toEntity().hours.initialId,
      '11am',
    );
  });
  test(
    'UTF-8 response is decoded independently of a missing charset header',
    () async {
      final data = fixtureJson('feed');
      data['user']['greeting'] = 'Bună, Jonathan';
      final repo = fixtureRepository(
        handler: (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(data)), 200),
      );
      expect((await repo.getFeed()).greeting, 'Bună, Jonathan');
    },
  );
  for (final status in [404, 500, 503]) {
    test('HTTP $status maps to a safe domain failure', () async {
      final repo = fixtureRepository(
        handler: (_) async =>
            http.Response('<html>server failure</html>', status),
      );
      await expectLater(
        repo.getFeed(),
        throwsA(
          isA<AppFailure>()
              .having(
                (f) => f.kind,
                'kind',
                status == 404 ? FailureKind.notFound : FailureKind.server,
              )
              .having((f) => f.statusCode, 'statusCode', status),
        ),
      );
    });
  }
  for (final body in ['not json', '[]', '{}']) {
    test('Invalid JSON/schema $body maps to invalidData', () async {
      final repo = fixtureRepository(
        handler: (_) async => http.Response(body, 200),
      );
      await expectLater(
        repo.getFeed(),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.kind,
            'kind',
            FailureKind.invalidData,
          ),
        ),
      );
    });
  }
  test('Disconnected client maps to network failure', () async {
    final repo = fixtureRepository(
      handler: (_) async => throw http.ClientException('DNS failed'),
    );
    await expectLater(
      repo.getFeed(),
      throwsA(
        isA<AppFailure>().having((f) => f.kind, 'kind', FailureKind.network),
      ),
    );
  });
  test('Unresponsive server maps to timeout', () async {
    final pending = Completer<http.Response>();
    final repo = HttpDoctorsRepository(
      DoctorsRemoteDataSource(
        MockClient((_) => pending.future),
        timeout: const Duration(milliseconds: 10),
      ),
    );
    await expectLater(
      repo.getFeed(),
      throwsA(
        isA<AppFailure>().having((f) => f.kind, 'kind', FailureKind.timeout),
      ),
    );
    pending.complete(http.Response(fixture('feed'), 200));
  });
  test('Duplicate IDs and invalid price are rejected', () {
    final feed = fixtureJson('feed');
    feed['nearbyDoctors'].add(feed['nearbyDoctors'][0]);
    expect(() => FeedDto.fromJson(feed), throwsFormatException);
    final details = fixtureJson('details');
    details['payment']['amount'] = -1;
    expect(() => AppointmentDto.fromJson(details), throwsFormatException);
  });
}
