import '../../domain/entities/catalog.dart';

typedef Json = Map<String, dynamic>;

// Strict DTO parsing: broken contracts become a controlled invalidData failure.
Json object(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Expected object: $field');
  }
  return value;
}

String text(Json j, String key) {
  final value = j[key];
  if (value is! String) throw FormatException('Expected string: $key');
  return value;
}

bool flag(Json j, String key, {bool? fallback}) {
  final value = j[key];
  if (value == null && fallback != null) return fallback;
  if (value is! bool) throw FormatException('Expected bool: $key');
  return value;
}

List<Json> objects(Json j, String key) {
  final value = j[key];
  if (value is! List) throw FormatException('Expected list: $key');
  return value.map((e) => object(e, key)).toList();
}

void uniqueIds(Iterable<String> ids) {
  final values = ids.toList();
  if (values.any((id) => id.isEmpty) ||
      values.toSet().length != values.length) {
    throw const FormatException('IDs must be nonempty and unique');
  }
}

class DoctorDto {
  const DoctorDto(this.entity);
  final Doctor entity;
  factory DoctorDto.fromJson(Json j, {String? id, bool clinic = false}) =>
      DoctorDto(
        Doctor(
          id: id ?? text(j, 'id'),
          name: text(j, 'name'),
          specialty: text(j, clinic ? 'clinic' : 'specialty'),
          avatarUrl: text(j, 'avatarUrl'),
          distance: j.containsKey('distance') ? text(j, 'distance') : '',
          isFavorite: flag(j, 'isFavorite', fallback: false),
        ),
      );
  Doctor toEntity() => entity;
  Json toJson({bool includeIdentity = true, bool clinic = false}) => {
    if (includeIdentity) 'id': entity.id,
    'name': entity.name,
    clinic ? 'clinic' : 'specialty': entity.specialty,
    'avatarUrl': entity.avatarUrl,
    if (includeIdentity) 'distance': entity.distance,
    if (includeIdentity) 'isFavorite': entity.isFavorite,
  };
}

class FeedDto {
  const FeedDto(this.entity);
  final Catalog entity;
  factory FeedDto.fromJson(Json j) {
    final user = object(j['user'], 'user');
    final notifications = object(j['notifications'], 'notifications');
    final search = object(j['search'], 'search');
    final appointment = object(j['appointment'], 'appointment');
    final doctors = objects(
      j,
      'nearbyDoctors',
    ).map((d) => DoctorDto.fromJson(d).toEntity()).toList();
    final services = objects(j, 'healthServices')
        .map(
          (s) =>
              HealthService(text(s, 'id'), text(s, 'name'), text(s, 'iconUrl')),
        )
        .toList();
    uniqueIds(doctors.map((d) => d.id));
    uniqueIds(services.map((s) => s.id));
    return FeedDto(
      Catalog(
        userName: text(user, 'name'),
        greeting: text(user, 'greeting'),
        subtitle: text(user, 'subtitle'),
        userAvatar: text(user, 'avatarUrl'),
        hasUnread: flag(notifications, 'hasUnread'),
        searchHint: text(search, 'hint'),
        appointmentTitle: text(appointment, 'title'),
        appointmentDate: text(appointment, 'date'),
        appointmentTime: text(appointment, 'time'),
        appointmentDoctor: DoctorDto.fromJson(
          object(appointment['doctor'], 'appointment.doctor'),
          id: 'home-appointment',
        ).toEntity(),
        services: services,
        doctors: doctors,
      ),
    );
  }
  Catalog toEntity() => entity;
  Json toJson() => {
    'user': {
      'name': entity.userName,
      'greeting': entity.greeting,
      'subtitle': entity.subtitle,
      'avatarUrl': entity.userAvatar,
    },
    'notifications': {'hasUnread': entity.hasUnread},
    'search': {'hint': entity.searchHint},
    'appointment': {
      'title': entity.appointmentTitle,
      'date': entity.appointmentDate,
      'time': entity.appointmentTime,
      'doctor': DoctorDto(entity.appointmentDoctor)
          .toJson(includeIdentity: false),
    },
    'healthServices': [
      for (final service in entity.services)
        {'id': service.id, 'name': service.name, 'iconUrl': service.iconUrl},
    ],
    'nearbyDoctors': [
      for (final doctor in entity.doctors) DoctorDto(doctor).toJson(),
    ],
  };
}

class SlotGroupDto {
  const SlotGroupDto(this.entity, this.showAll);
  final SlotGroup entity;
  final bool showAll;
  factory SlotGroupDto.fromJson(Json j) {
    final slots = objects(j, 'slots')
        .map(
          (s) => ChoiceSlot(
            text(s, 'id'),
            text(s, 'label'),
            flag(s, 'selected', fallback: false),
          ),
        )
        .toList();
    uniqueIds(slots.map((s) => s.id));
    return SlotGroupDto(
      SlotGroup(title: text(j, 'title'), slots: slots),
      flag(j, 'showAll', fallback: false),
    );
  }
  Json toJson() => {
    'title': entity.title,
    'showAll': showAll,
    'slots': [
      for (final s in entity.slots)
        {'id': s.id, 'label': s.label, 'selected': s.selected},
    ],
  };
}

class AppointmentDto {
  const AppointmentDto(
    this.entity, {
    this.showAllHours = true,
    this.showAllDates = true,
  });
  final AppointmentData entity;
  final bool showAllHours, showAllDates;
  factory AppointmentDto.fromJson(Json j) {
    final doctor = object(j['doctor'], 'doctor');
    final payment = object(j['payment'], 'payment');
    final details = object(j['details'], 'details');
    final booking = object(
      object(j['actions'], 'actions')['bookAppointment'],
      'bookAppointment',
    );
    final hours = SlotGroupDto.fromJson(
      object(j['workingHours'], 'workingHours'),
    );
    final dates = SlotGroupDto.fromJson(object(j['date'], 'date'));
    final amount = payment['amount'];
    if (amount is! num || !amount.isFinite || amount < 0) {
      throw const FormatException('Invalid amount');
    }
    final rawActions = object(doctor['actions'], 'doctor.actions');
    final actions = {
      for (final key in rawActions.keys) key: flag(rawActions, key),
    };
    return AppointmentDto(
      AppointmentData(
        title: text(j, 'title'),
        doctor: DoctorDto.fromJson(
          doctor,
          id: 'appointment-doctor',
          clinic: true,
        ).toEntity(),
        paymentLabel: text(payment, 'label'),
        paymentFormatted: text(payment, 'formatted'),
        amount: amount.toDouble(),
        currency: text(payment, 'currency'),
        detailsTitle: text(details, 'title'),
        description: text(details, 'description'),
        hours: hours.entity,
        dates: dates.entity,
        bookLabel: text(booking, 'label'),
        bookingEnabled: flag(booking, 'enabled'),
        actions: actions,
      ),
      showAllHours: hours.showAll,
      showAllDates: dates.showAll,
    );
  }
  AppointmentData toEntity() => entity;
  Json toJson() => {
    'title': entity.title,
    'doctor': {
      ...DoctorDto(entity.doctor).toJson(includeIdentity: false, clinic: true),
      'actions': entity.actions,
    },
    'payment': {
      'label': entity.paymentLabel,
      'amount': entity.amount,
      'currency': entity.currency,
      'formatted': entity.paymentFormatted,
    },
    'details': {
      'title': entity.detailsTitle,
      'description': entity.description,
    },
    'workingHours': SlotGroupDto(entity.hours, showAllHours).toJson(),
    'date': SlotGroupDto(entity.dates, showAllDates).toJson(),
    'actions': {
      'bookAppointment': {
        'label': entity.bookLabel,
        'enabled': entity.bookingEnabled,
      },
    },
  };
}
