import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lab4/data/datasources/doctors_remote_data_source.dart';
import 'package:lab4/data/models/api_dtos.dart';
import 'package:lab4/data/repositories/http_doctors_repository.dart';
import 'package:lab4/domain/usecases/get_doctors.dart';

// Optional live smoke test, separate from deterministic tests. No server writes.
Future<void> main() async {
  final client = http.Client();
  try {
    final repository = HttpDoctorsRepository(DoctorsRemoteDataSource(client));
    final feed = await GetDoctors(repository)();
    final details = await GetAppointmentDetails(repository)();
    final roundTrip = FeedDto.fromJson(
      jsonDecode(jsonEncode(FeedDto(feed).toJson())) as Json,
    ).toEntity();
    if (roundTrip.doctors.length != feed.doctors.length) {
      throw StateError('Serialization mismatch');
    }
    stdout.writeln(
      'LIVE API OK: ${feed.doctors.length} doctors; ${details.doctor.name}; ${details.currency} ${details.amount}; ${details.hours.slots.length} slots.',
    );
  } finally {
    client.close();
  }
}
