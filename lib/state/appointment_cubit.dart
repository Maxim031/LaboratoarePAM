import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/catalog.dart';

class AppointmentState {
  const AppointmentState({this.timeId, this.dateId, this.confirmed = false});
  final String? timeId, dateId;
  final bool confirmed;
}

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit(this.data)
    : super(
        AppointmentState(
          timeId: data.hours.initialId,
          dateId: data.dates.initialId,
        ),
      );
  final AppointmentData data;
  void selectTime(String id) {
    if (data.hours.slots.any((s) => s.id == id)) {
      emit(AppointmentState(timeId: id, dateId: state.dateId));
    }
  }

  void selectDate(String id) {
    if (data.dates.slots.any((s) => s.id == id)) {
      emit(AppointmentState(timeId: state.timeId, dateId: id));
    }
  }

  void confirm() {
    if (data.bookingEnabled &&
        state.timeId != null &&
        state.dateId != null &&
        !state.confirmed) {
      emit(
        AppointmentState(
          timeId: state.timeId,
          dateId: state.dateId,
          confirmed: true,
        ),
      );
    }
  }
}
