import '../entities/catalog.dart';

abstract interface class DoctorsRepository {
  Future<Catalog> getFeed();
  Future<AppointmentData> getAppointmentDetails();
}
