import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/catalog.dart';

class CatalogRepository {
  CatalogRepository({Future<String> Function()? loadText})
    : _loadText =
          loadText ?? (() => rootBundle.loadString('assets/data/lab_v2.json'));
  final Future<String> Function() _loadText;

  Future<Catalog> load() async {
    final text = await _loadText();
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return Catalog.fromJson(decoded);
  }
}
