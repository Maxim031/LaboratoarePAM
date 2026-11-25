import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_dtos.dart';

enum ApiErrorKind { timeout, network, httpStatus, invalidJson }

class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode});
  final ApiErrorKind kind;
  final int? statusCode;
}

class DoctorsRemoteDataSource {
  DoctorsRemoteDataSource(
    this.client, {
    Uri? baseUri,
    this.timeout = const Duration(seconds: 60),
  }) : baseUri =
           baseUri ??
           Uri.parse('https://test-api-jlbn.onrender.com/lab2026/v2/');
  final http.Client client;
  final Uri baseUri;
  final Duration timeout;

  Future<Json> getFeed() => _get('feed');
  Future<Json> getDetails() => _get('feed/details');

  Future<Json> _get(String path) async {
    try {
      // No local JSON fallback: displayed business data must come from HTTP.
      final response = await client
          .get(baseUri.resolve(path), headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          ApiErrorKind.httpStatus,
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return object(decoded, path);
    } on TimeoutException {
      throw const ApiException(ApiErrorKind.timeout);
    } on http.ClientException {
      throw const ApiException(ApiErrorKind.network);
    } on FormatException {
      throw const ApiException(ApiErrorKind.invalidJson);
    }
  }
}
