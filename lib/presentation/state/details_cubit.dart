import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/usecases/get_doctors.dart';

sealed class DetailsState {
  const DetailsState();
}

class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

class DetailsSuccess extends DetailsState {
  const DetailsSuccess(this.data);
  final AppointmentData data;
}

class DetailsError extends DetailsState {
  const DetailsError(this.message);
  final String message;
}

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit(this.getDetails) : super(const DetailsLoading());
  final GetAppointmentDetails getDetails;
  int _request = 0;
  Future<void> load() async {
    final request = ++_request;
    emit(const DetailsLoading());
    try {
      final details = await getDetails();
      if (!isClosed && request == _request) emit(DetailsSuccess(details));
    } on AppFailure catch (failure) {
      if (!isClosed && request == _request) emit(DetailsError(failure.message));
    } catch (_) {
      if (!isClosed && request == _request) {
        emit(
          const DetailsError(
            'Unable to load appointment details. Please try again.',
          ),
        );
      }
    }
  }
}
