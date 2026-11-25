// Pure Dart entities. Domain has no Flutter, HTTP or JSON dependencies.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    this.distance = '',
    this.isFavorite = false,
  });
  final String id, name, specialty, avatarUrl, distance;
  final bool isFavorite;
  double get distanceMeters {
    final match = RegExp(
      r'(\d+(?:\.\d+)?)\s*(km|m)\s+from you',
      caseSensitive: false,
    ).firstMatch(distance);
    if (match == null) return double.infinity;
    return double.parse(match[1]!) *
        (match[2]!.toLowerCase() == 'km' ? 1000 : 1);
  }
}

class HealthService {
  const HealthService(this.id, this.name, this.iconUrl);
  final String id, name, iconUrl;
}

class ChoiceSlot {
  const ChoiceSlot(this.id, this.label, this.selected);
  final String id, label;
  final bool selected;
}

class SlotGroup {
  SlotGroup({required this.title, required List<ChoiceSlot> slots})
    : slots = List.unmodifiable(slots);
  final String title;
  final List<ChoiceSlot> slots;
  String? get initialId => slots.isEmpty
      ? null
      : slots.firstWhere((s) => s.selected, orElse: () => slots.first).id;
}

class AppointmentData {
  AppointmentData({
    required this.title,
    required this.doctor,
    required this.paymentLabel,
    required this.paymentFormatted,
    required this.amount,
    required this.currency,
    required this.detailsTitle,
    required this.description,
    required this.hours,
    required this.dates,
    required this.bookLabel,
    required this.bookingEnabled,
    required Map<String, bool> actions,
  }) : actions = Map.unmodifiable(actions);
  final String title,
      paymentLabel,
      paymentFormatted,
      currency,
      detailsTitle,
      description,
      bookLabel;
  final double amount;
  final Doctor doctor;
  final SlotGroup hours, dates;
  final bool bookingEnabled;
  final Map<String, bool> actions;
}

class Catalog {
  Catalog({
    required this.userName,
    required this.greeting,
    required this.subtitle,
    required this.userAvatar,
    required this.hasUnread,
    required this.searchHint,
    required this.appointmentTitle,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentDoctor,
    required List<HealthService> services,
    required List<Doctor> doctors,
  }) : services = List.unmodifiable(services),
       doctors = List.unmodifiable(doctors);
  final String userName,
      greeting,
      subtitle,
      userAvatar,
      searchHint,
      appointmentTitle,
      appointmentDate,
      appointmentTime;
  final bool hasUnread;
  final Doctor appointmentDoctor;
  final List<HealthService> services;
  final List<Doctor> doctors;
}
