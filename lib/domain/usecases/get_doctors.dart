import '../entities/catalog.dart';
import '../repositories/doctors_repository.dart';

class GetDoctors {
  const GetDoctors(this.repository);
  final DoctorsRepository repository;
  Future<Catalog> call() => repository.getFeed();
}

class GetAppointmentDetails {
  const GetAppointmentDetails(this.repository);
  final DoctorsRepository repository;
  Future<AppointmentData> call() => repository.getAppointmentDetails();
}
