// Typed models for the supplied variant-2 JSON. Invalid data reaches Error state.
typedef Json = Map<String, dynamic>;

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
  factory Doctor.fromJson(Json json, {String? id}) => Doctor(
    id: id ?? json['id'] as String,
    name: json['name'] as String,
    specialty: (json['specialty'] ?? json['clinic']) as String,
    avatarUrl: json['avatarUrl'] as String,
    distance: json['distance'] as String? ?? '',
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
  // The supplied distance is text, e.g. "... - 500M from you".
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
  factory HealthService.fromJson(Json j) => HealthService(
    j['id'] as String,
    j['name'] as String,
    j['iconUrl'] as String,
  );
}

class ChoiceSlot {
  const ChoiceSlot(this.id, this.label, this.selected);
  final String id, label;
  final bool selected;
  factory ChoiceSlot.fromJson(Json j) => ChoiceSlot(
    j['id'] as String,
    j['label'] as String,
    j['selected'] as bool? ?? false,
  );
}

class SlotGroup {
  SlotGroup.fromJson(Json j)
    : title = j['title'] as String,
      slots = List.unmodifiable(
        (j['slots'] as List).map((e) => ChoiceSlot.fromJson(e as Json)),
      );
  final String title;
  final List<ChoiceSlot> slots;
  String? get initialId {
    if (slots.isEmpty) return null;
    return slots.firstWhere((s) => s.selected, orElse: () => slots.first).id;
  }
}

class AppointmentData {
  AppointmentData.fromJson(Json j)
    : title = j['title'] as String,
      doctor = Doctor.fromJson(j['doctor'] as Json, id: 'appointment-doctor'),
      paymentLabel = j['payment']['label'] as String,
      paymentFormatted = j['payment']['formatted'] as String,
      amount = (j['payment']['amount'] as num).toDouble(),
      currency = j['payment']['currency'] as String,
      detailsTitle = j['details']['title'] as String,
      description = j['details']['description'] as String,
      hours = SlotGroup.fromJson(j['workingHours'] as Json),
      dates = SlotGroup.fromJson(j['date'] as Json),
      bookLabel = j['actions']['bookAppointment']['label'] as String,
      bookingEnabled = j['actions']['bookAppointment']['enabled'] as bool,
      actions = Map.unmodifiable(
        Map<String, bool>.from(j['doctor']['actions'] as Map),
      );
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
  Catalog.fromJson(Json j)
    : greeting = j['homeScreen']['user']['greeting'] as String,
      subtitle = j['homeScreen']['user']['subtitle'] as String,
      userAvatar = j['homeScreen']['user']['avatarUrl'] as String,
      hasUnread = j['homeScreen']['notifications']['hasUnread'] as bool,
      searchHint = j['homeScreen']['search']['hint'] as String,
      appointmentTitle = j['homeScreen']['appointment']['title'] as String,
      appointmentDate = j['homeScreen']['appointment']['date'] as String,
      appointmentTime = j['homeScreen']['appointment']['time'] as String,
      appointmentDoctor = Doctor.fromJson(
        j['homeScreen']['appointment']['doctor'] as Json,
        id: 'home-appointment',
      ),
      services = List.unmodifiable(
        (j['homeScreen']['healthServices'] as List).map(
          (e) => HealthService.fromJson(e as Json),
        ),
      ),
      doctors = List.unmodifiable(
        (j['homeScreen']['nearbyDoctors'] as List).map(
          (e) => Doctor.fromJson(e as Json),
        ),
      ),
      appointment = AppointmentData.fromJson(j['appointmentDetails'] as Json) {
    if (doctors.map((d) => d.id).toSet().length != doctors.length) {
      throw const FormatException('Doctor IDs must be unique.');
    }
  }
  final String greeting,
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
  final AppointmentData appointment;
}
