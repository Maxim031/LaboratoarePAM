import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lab4/data/models/api_dtos.dart';
import 'package:lab4/domain/usecases/get_doctors.dart';
import 'package:lab4/domain/usecases/select_doctors.dart';
import 'package:lab4/presentation/state/doctors_cubit.dart';
import 'package:lab4/presentation/state/details_cubit.dart';
import 'package:lab4/presentation/state/appointment_cubit.dart';

import 'helpers.dart';

void main() {
  test('Loading is observable before asynchronous HTTP success', () async {
    final pending = Completer<http.Response>();
    final cubit = DoctorsCubit(
      GetDoctors(fixtureRepository(handler: (_) => pending.future)),
    );
    addTearDown(cubit.close);
    final request = cubit.load();
    expect(cubit.state.status, LoadStatus.loading);
    pending.complete(http.Response(fixture('feed'), 200));
    await request;
    expect(cubit.state.status, LoadStatus.success);
  });
  test('Search, specialty and favorites compose and reset', () async {
    final cubit = DoctorsCubit(GetDoctors(fixtureRepository()));
    addTearDown(cubit.close);
    await cubit.load();
    cubit.search(' SONJA ');
    expect(cubit.state.visible.single.id, 'doctor-002');
    cubit.toggleFavorite('doctor-002');
    cubit.filterFavorites(true);
    cubit.filterSpecialty('Dental Specialist');
    expect(cubit.state.visible.single.id, 'doctor-002');
    cubit.toggleFavorite('doctor-002');
    expect(cubit.state.status, LoadStatus.empty);
    cubit.clearFilters();
    expect(cubit.state.visible.length, 2);
  });
  test('Domain use case sorts by name and numeric distance', () {
    final doctors = FeedDto.fromJson(fixtureJson('feed')).toEntity().doctors;
    const select = SelectDoctors();
    expect(
      select(doctors, sort: DoctorSort.nameDescending).first.id,
      'doctor-002',
    );
    expect(
      select(doctors, sort: DoctorSort.nameAscending).first.id,
      'doctor-001',
    );
    expect(select(doctors, sort: DoctorSort.nearest).first.distanceMeters, 500);
  });
  test('An empty server dataset produces Empty', () async {
    final data = fixtureJson('feed');
    data['nearbyDoctors'] = [];
    final cubit = DoctorsCubit(
      GetDoctors(
        fixtureRepository(
          handler: (_) async => http.Response(jsonEncode(data), 200),
        ),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, LoadStatus.empty);
  });
  test('HTTP failure retains favorites and retry recovers', () async {
    var fail = false;
    final cubit = DoctorsCubit(
      GetDoctors(
        fixtureRepository(
          handler: (_) async =>
              http.Response(fail ? '' : fixture('feed'), fail ? 503 : 200),
        ),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    cubit.toggleFavorite('doctor-001');
    fail = true;
    await cubit.load();
    expect(cubit.state.status, LoadStatus.error);
    expect(cubit.state.error, contains('503'));
    fail = false;
    await cubit.load();
    expect(cubit.state.favorites, {'doctor-001'});
  });
  test('Late old response does not override newer request', () async {
    var count = 0;
    final pending = Completer<http.Response>();
    final cubit = DoctorsCubit(
      GetDoctors(
        fixtureRepository(
          handler: (_) => count++ == 0
              ? pending.future
              : Future.value(http.Response(fixture('feed'), 200)),
        ),
      ),
    );
    addTearDown(cubit.close);
    final old = cubit.load();
    await cubit.load();
    pending.complete(http.Response('', 500));
    await old;
    expect(cubit.state.status, LoadStatus.success);
  });
  test('Details has independent HTTP loading, error and retry', () async {
    var fail = true;
    final cubit = DetailsCubit(
      GetAppointmentDetails(
        fixtureRepository(
          handler: (_) async =>
              http.Response(fail ? '' : fixture('details'), fail ? 500 : 200),
        ),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state, isA<DetailsError>());
    fail = false;
    await cubit.load();
    expect(cubit.state, isA<DetailsSuccess>());
  });
  test('Closed cubit safely ignores outstanding HTTP request', () async {
    final pending = Completer<http.Response>();
    final cubit = DetailsCubit(
      GetAppointmentDetails(fixtureRepository(handler: (_) => pending.future)),
    );
    final request = cubit.load();
    await cubit.close();
    pending.complete(http.Response(fixture('details'), 200));
    await request;
    expect(cubit.isClosed, isTrue);
  });
  test(
    'Appointment validates slots and preserves explicit local confirmation',
    () {
      final cubit = AppointmentCubit(
        AppointmentDto.fromJson(fixtureJson('details')).toEntity(),
      );
      addTearDown(cubit.close);
      cubit.selectTime('invalid');
      expect(cubit.state.timeId, '11am');
      cubit.selectTime('10am');
      cubit.selectDate('mon-5');
      cubit.confirm();
      expect(cubit.state.confirmed, isTrue);
      cubit.selectDate('tue-6');
      expect(cubit.state.confirmed, isFalse);
    },
  );
}
