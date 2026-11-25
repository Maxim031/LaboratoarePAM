import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab4/data/datasources/doctors_remote_data_source.dart';
import 'package:lab4/data/models/api_dtos.dart';
import 'package:lab4/data/repositories/http_doctors_repository.dart';

String fixture(String name) =>
    File('test/fixtures/$name.json')
        .readAsStringSync()
        .replaceFirst('\ufeff', '');
Json fixtureJson(String name) => jsonDecode(fixture(name)) as Json;
HttpDoctorsRepository fixtureRepository({
  Future<http.Response> Function(http.Request)? handler,
}) => HttpDoctorsRepository(
  DoctorsRemoteDataSource(
    MockClient(
      handler ??
          (request) async => http.Response(
            fixture(request.url.path.endsWith('/details') ? 'details' : 'feed'),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
    ),
  ),
);
