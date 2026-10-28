import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab3/data/catalog_repository.dart';
import 'package:lab3/models/catalog.dart';
import 'package:lab3/state/doctors_cubit.dart';
import 'package:lab3/state/appointment_cubit.dart';

void main() {
  final fixture = File('assets/data/lab_v2.json').readAsStringSync();
  CatalogRepository repository([String? json]) =>
      CatalogRepository(loadText: () async => json ?? fixture);

  test('Async loading emits Loading then Success with parsed JSON', () async {
    final completer = Completer<String>();
    final cubit = DoctorsCubit(
      CatalogRepository(loadText: () => completer.future),
    );
    addTearDown(cubit.close);
    final states = <LoadStatus>[];
    final subscription = cubit.stream.listen((s) => states.add(s.status));
    addTearDown(subscription.cancel);
    final loading = cubit.load();
    expect(cubit.state.status, LoadStatus.loading);
    completer.complete(fixture);
    await loading;
    await Future<void>.delayed(Duration.zero);
    expect(states, [LoadStatus.loading, LoadStatus.success]);
    expect(cubit.state.visible.length, 2);
    expect(cubit.state.catalog!.appointment.amount, 120);
  });

  test(
    'Case-insensitive search, specialty and favorites compose and reset',
    () async {
      final cubit = DoctorsCubit(repository());
      addTearDown(cubit.close);
      await cubit.load();
      cubit.search('  SONJA ');
      expect(cubit.state.visible.single.id, 'doctor-002');
      cubit.toggleFavorite('doctor-002');
      cubit.filterFavorites(true);
      cubit.filterSpecialty('Dental Specialist');
      expect(cubit.state.visible.single.id, 'doctor-002');
      cubit.toggleFavorite('doctor-002');
      expect(cubit.state.status, LoadStatus.empty);
      cubit.clearFilters();
      expect(cubit.state.visible.length, 2);
      cubit.filterSpecialty('Ophthalmologist');
      expect(cubit.state.status, LoadStatus.empty);
    },
  );

  test(
    'Sorting uses names and numeric distances; favorites survive reload',
    () async {
      final cubit = DoctorsCubit(repository());
      addTearDown(cubit.close);
      await cubit.load();
      cubit.changeSort(DoctorSort.nameDescending);
      expect(cubit.state.visible.first.id, 'doctor-002');
      cubit.changeSort(DoctorSort.nameAscending);
      expect(cubit.state.visible.first.id, 'doctor-001');
      cubit.changeSort(DoctorSort.nearest);
      expect(cubit.state.visible.first.distanceMeters, 500);
      cubit.toggleFavorite('doctor-001');
      await cubit.load();
      expect(cubit.state.favorites, {'doctor-001'});
    },
  );

  test(
    'Empty dataset is Empty, invalid JSON is Error and retry recovers',
    () async {
      final empty = jsonDecode(fixture) as Json;
      empty['homeScreen']['nearbyDoctors'] = [];
      final cubit = DoctorsCubit(repository(jsonEncode(empty)));
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.status, LoadStatus.empty);
      var fail = true;
      final retry = DoctorsCubit(
        CatalogRepository(loadText: () async => fail ? '{broken' : fixture),
      );
      addTearDown(retry.close);
      await retry.load();
      expect(retry.state.status, LoadStatus.error);
      fail = false;
      await retry.load();
      expect(retry.state.status, LoadStatus.success);
    },
  );

  test('Missing asset and malformed schema reach Error', () async {
    for (final loader in <Future<String> Function()>[
      () async => throw StateError('Asset unavailable'),
      () async => '{}',
    ]) {
      final cubit = DoctorsCubit(CatalogRepository(loadText: loader));
      await cubit.load();
      expect(cubit.state.status, LoadStatus.error);
      await cubit.close();
    }
  });

  test(
    'Latest load wins when asynchronous requests complete out of order',
    () async {
      final first = Completer<String>();
      var calls = 0;
      final cubit = DoctorsCubit(
        CatalogRepository(
          loadText: () => calls++ == 0 ? first.future : Future.value(fixture),
        ),
      );
      addTearDown(cubit.close);
      final old = cubit.load();
      await cubit.load();
      first.complete('invalid');
      await old;
      expect(cubit.state.status, LoadStatus.success);
    },
  );

  test('Appointment selections come from JSON and invalid IDs are ignored', () {
    final data = Catalog.fromJson(jsonDecode(fixture) as Json).appointment;
    final cubit = AppointmentCubit(data);
    addTearDown(cubit.close);
    expect(cubit.state.timeId, '11am');
    expect(cubit.state.dateId, 'sun-4');
    cubit.selectTime('bad-id');
    expect(cubit.state.timeId, '11am');
    cubit.selectTime('10am');
    cubit.selectDate('mon-5');
    cubit.confirm();
    expect(cubit.state.confirmed, isTrue);
    expect(cubit.state.timeId, '10am');
    cubit.selectDate('tue-6');
    expect(cubit.state.confirmed, isFalse);
  });
}
