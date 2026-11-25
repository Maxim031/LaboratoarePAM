import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_doctors.dart';
import '../../domain/usecases/select_doctors.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/entities/catalog.dart';

enum LoadStatus { loading, success, empty, error }

class DoctorsState {
  DoctorsState({
    this.status = LoadStatus.loading,
    this.catalog,
    this.query = '',
    this.specialty = '',
    this.favoritesOnly = false,
    this.sort = DoctorSort.nearest,
    Set<String> favorites = const {},
    List<Doctor> visible = const [],
    this.error,
  }) : favorites = Set.unmodifiable(favorites),
       visible = List.unmodifiable(visible);
  final LoadStatus status;
  final Catalog? catalog;
  final String query, specialty;
  final bool favoritesOnly;
  final DoctorSort sort;
  final Set<String> favorites;
  final List<Doctor> visible;
  final String? error;
}

class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit(this.getDoctors) : super(DoctorsState());
  final GetDoctors getDoctors;
  int _request = 0;
  bool _favoritesInitialized = false;

  Future<void> load() async {
    final request = ++_request;
    emit(DoctorsState(status: LoadStatus.loading, favorites: state.favorites));
    try {
      final data = await getDoctors();
      if (isClosed || request != _request) return;
      final favorites = _favoritesInitialized
          ? state.favorites
          : data.doctors.where((d) => d.isFavorite).map((d) => d.id).toSet();
      _favoritesInitialized = true;
      _apply(
        catalog: data,
        favorites: favorites.intersection(
          data.doctors.map((d) => d.id).toSet(),
        ),
      );
    } catch (failure) {
      if (isClosed || request != _request) return;
      emit(
        DoctorsState(
          status: LoadStatus.error,
          favorites: state.favorites,
          error: failure is AppFailure
              ? failure.message
              : 'Could not load the doctors. Please try again.',
        ),
      );
    }
  }

  void search(String value) => _apply(query: value);
  void filterSpecialty(String value) => _apply(specialty: value);
  void filterFavorites(bool value) => _apply(favoritesOnly: value);
  void changeSort(DoctorSort value) => _apply(sort: value);
  void clearFilters() => _apply(query: '', specialty: '', favoritesOnly: false);
  void toggleFavorite(String id) {
    if (state.catalog?.doctors.any((d) => d.id == id) != true) return;
    final updated = {...state.favorites};
    updated.contains(id) ? updated.remove(id) : updated.add(id);
    _apply(favorites: updated);
  }

  void _apply({
    Catalog? catalog,
    String? query,
    String? specialty,
    bool? favoritesOnly,
    DoctorSort? sort,
    Set<String>? favorites,
  }) {
    final data = catalog ?? state.catalog;
    if (data == null) return;
    final q = query ?? state.query;
    final category = specialty ?? state.specialty;
    final onlyFavorites = favoritesOnly ?? state.favoritesOnly;
    final order = sort ?? state.sort;
    final ids = favorites ?? state.favorites;
    final visible = const SelectDoctors()(
      data.doctors,
      query: q,
      specialty: category,
      favoritesOnly: onlyFavorites,
      favorites: ids,
      sort: order,
    );
    emit(
      DoctorsState(
        status: visible.isEmpty ? LoadStatus.empty : LoadStatus.success,
        catalog: data,
        query: q,
        specialty: category,
        favoritesOnly: onlyFavorites,
        sort: order,
        favorites: ids,
        visible: visible,
      ),
    );
  }
}
