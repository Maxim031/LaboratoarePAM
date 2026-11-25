import '../entities/catalog.dart';

enum DoctorSort { nameAscending, nameDescending, nearest }

class SelectDoctors {
  const SelectDoctors();
  List<Doctor> call(
    List<Doctor> doctors, {
    String query = '',
    String specialty = '',
    bool favoritesOnly = false,
    Set<String> favorites = const {},
    DoctorSort sort = DoctorSort.nearest,
  }) {
    final term = query.trim().toLowerCase();
    final result = doctors
        .where(
          (d) =>
              '${d.name} ${d.specialty}'.toLowerCase().contains(term) &&
              (specialty.isEmpty || d.specialty == specialty) &&
              (!favoritesOnly || favorites.contains(d.id)),
        )
        .toList();
    result.sort(
      (a, b) => switch (sort) {
        DoctorSort.nameAscending => a.name.compareTo(b.name),
        DoctorSort.nameDescending => b.name.compareTo(a.name),
        DoctorSort.nearest => a.distanceMeters.compareTo(b.distanceMeters),
      },
    );
    return List.unmodifiable(result);
  }
}
