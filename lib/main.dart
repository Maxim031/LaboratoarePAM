import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'data/datasources/doctors_remote_data_source.dart';
import 'data/repositories/http_doctors_repository.dart';

void main() => runApp(const _CompositionRoot());

// Own the HTTP client for the application's lifetime; don't create it on rebuild.
class _CompositionRoot extends StatefulWidget {
  const _CompositionRoot();
  @override
  State<_CompositionRoot> createState() => _CompositionRootState();
}

class _CompositionRootState extends State<_CompositionRoot> {
  final client = http.Client();
  late final repository = HttpDoctorsRepository(
    DoctorsRemoteDataSource(client),
  );
  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DoctorApp(repository: repository);
}
