import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/catalog.dart';
import '../state/appointment_cubit.dart';
import '../state/doctors_cubit.dart';
import '../widgets/common.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.doctor, required this.data});
  final Doctor doctor;
  final AppointmentData data;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AppointmentCubit(data),
    child: _DetailsBody(doctor: doctor, data: data),
  );
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.doctor, required this.data});
  final Doctor doctor;
  final AppointmentData data;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        data.title,
        style: const TextStyle(color: teal, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        if (doctor.id.startsWith('doctor-'))
          BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) => IconButton(
              tooltip: 'Toggle favorite',
              onPressed: () =>
                  context.read<DoctorsCubit>().toggleFavorite(doctor.id),
              icon: Icon(
                state.favorites.contains(doctor.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: teal,
              ),
            ),
          ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              final cubit = context.read<AppointmentCubit>();
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Portrait(
                        asset: doctorAsset(doctor),
                        size: 110,
                        radius: 10,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              doctor.specialty,
                              style: const TextStyle(
                                color: Color(0xFF6AC4BA),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 5,
                              children: [
                                for (final action in data.actions.entries.where(
                                  (e) => e.value,
                                ))
                                  IconButton(
                                    tooltip: action.key,
                                    visualDensity: VisualDensity.compact,
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFFD8EEEA),
                                    ),
                                    onPressed: () =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Contact details are not provided in this dataset.',
                                                ),
                                              ),
                                            ),
                                    icon: Icon(
                                      switch (action.key) {
                                        'call' => Icons.phone_outlined,
                                        'videoCall' => Icons.videocam_outlined,
                                        _ => Icons.chat_bubble_outline,
                                      },
                                      size: 18,
                                      color: ink,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.paymentLabel,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Text(
                        data.paymentFormatted,
                        style: const TextStyle(
                          color: Color(0xFF6AC4BA),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (doctor.distance.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(doctor.distance, style: const TextStyle(color: muted)),
                  ],
                  const SizedBox(height: 28),
                  SectionHeading(data.detailsTitle),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    style: const TextStyle(color: muted, height: 1.45),
                  ),
                  const SizedBox(height: 32),
                  SlotSelector(
                    group: data.hours,
                    selected: state.timeId,
                    onSelect: cubit.selectTime,
                  ),
                  const SizedBox(height: 26),
                  SlotSelector(
                    group: data.dates,
                    selected: state.dateId,
                    onSelect: cubit.selectDate,
                  ),
                  const SizedBox(height: 36),
                  if (state.confirmed) ...[
                    Container(
                      key: const ValueKey('booking-confirmation'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F5F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Appointment selected for ${doctor.name}\n'
                        '${data.dates.slots.firstWhere((s) => s.id == state.dateId).label} · '
                        '${data.hours.slots.firstWhere((s) => s.id == state.timeId).label}\n'
                        'Saved for this session. No clinic has been contacted.',
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed:
                        data.bookingEnabled &&
                            state.timeId != null &&
                            state.dateId != null &&
                            !state.confirmed
                        ? cubit.confirm
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      state.confirmed ? 'Appointment selected' : data.bookLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
