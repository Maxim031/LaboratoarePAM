import '../../domain/entities/catalog.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctors_remote_data_source.dart';
import '../models/api_dtos.dart';

class HttpDoctorsRepository implements DoctorsRepository {
  const HttpDoctorsRepository(this.remote);
  final DoctorsRemoteDataSource remote;
  @override
  Future<Catalog> getFeed() =>
      _guard(() async => FeedDto.fromJson(await remote.getFeed()).toEntity());
  @override
  Future<AppointmentData> getAppointmentDetails() => _guard(
    () async => AppointmentDto.fromJson(await remote.getDetails()).toEntity(),
  );

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw switch (error.kind) {
        ApiErrorKind.timeout => const AppFailure(
          FailureKind.timeout,
          'The server is taking too long. Please try again.',
        ),
        ApiErrorKind.network => const AppFailure(
          FailureKind.network,
          'Cannot connect. Check your internet connection and try again.',
        ),
        ApiErrorKind.invalidJson => const AppFailure(
          FailureKind.invalidData,
          'The server returned invalid data. Please try again later.',
        ),
        ApiErrorKind.httpStatus => AppFailure(
          error.statusCode == 404 ? FailureKind.notFound : FailureKind.server,
          'The server could not complete the request (HTTP ${error.statusCode}). Please try again.',
          statusCode: error.statusCode,
        ),
      };
    } on FormatException {
      throw const AppFailure(
        FailureKind.invalidData,
        'The server data has an unexpected format. Please try again later.',
      );
    }
  }
}
