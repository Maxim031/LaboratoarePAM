import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/catalog.dart';
import '../state/doctors_cubit.dart';
import '../widgets/common.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void clearFilters() {
    searchController.clear();
    context.read<DoctorsCubit>().clearFilters();
  }

  void openDetails(Catalog data, Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(doctor: doctor, data: data.appointment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          final cubit = context.read<DoctorsCubit>();
          if (state.status == LoadStatus.loading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading doctors…'),
                ],
              ),
            );
          }
          if (state.status == LoadStatus.error) {
            return Center(
              child: StateMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Something went wrong',
                message: state.error!,
                actionLabel: 'Try again',
                onAction: () {
                  searchController.clear();
                  cubit.load();
                },
              ),
            );
          }
          final data = state.catalog!;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: RefreshIndicator(
                onRefresh: () async {
                  searchController.clear();
                  await cubit.load();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        const Portrait(asset: 'jonathan', size: 44),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.greeting,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.subtitle,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Badge(
                          isLabelVisible: data.hasUnread,
                          child: IconButton(
                            tooltip: 'Notifications',
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Appointment reminder'),
                                content: Text(
                                  '${data.appointmentDate}\n${data.appointmentTime}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.notifications_none),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: searchController,
                      onChanged: cubit.search,
                      decoration: InputDecoration(
                        hintText: data.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  searchController.clear();
                                  cubit.search('');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AppointmentCard(
                      data: data,
                      onOpen: () => openDetails(data, data.appointment.doctor),
                    ),
                    const SizedBox(height: 24),
                    SectionHeading('Health Services', action: clearFilters),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        for (final service in data.services)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              searchController.clear();
                              cubit.clearFilters();
                              // The JSON has no category IDs on doctors; use specialty names.
                              cubit.filterSpecialty(switch (service.id) {
                                'tooth' => 'Dental Specialist',
                                'eye' => 'Ophthalmologist',
                                'lungs' => 'Pulmonologist',
                                'ear' => 'ENT Specialist',
                                _ => '',
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 62,
                                  height: 60,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F7F8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    'assets/images/${service.id}.png',
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.medical_services_outlined,
                                      color: teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SectionHeading(
                      'Nearby Doctor',
                      action: clearFilters,
                      actionLabel: 'Reset',
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilterChip(
                          label: const Text('Favorites'),
                          avatar: const Icon(Icons.favorite_border, size: 18),
                          selected: state.favoritesOnly,
                          onSelected: cubit.filterFavorites,
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Filter by specialty',
                          onSelected: cubit.filterSpecialty,
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: '',
                              child: Text('All specialties'),
                            ),
                            for (final specialty
                                in data.doctors.map((d) => d.specialty).toSet())
                              PopupMenuItem(
                                value: specialty,
                                child: Text(specialty),
                              ),
                          ],
                          child: Chip(
                            avatar: const Icon(Icons.tune, size: 18),
                            label: Text(
                              state.specialty.isEmpty
                                  ? 'Specialty'
                                  : state.specialty,
                            ),
                          ),
                        ),
                        PopupMenuButton<DoctorSort>(
                          tooltip: 'Sort doctors',
                          onSelected: cubit.changeSort,
                          itemBuilder: (_) => [
                            for (final sort in DoctorSort.values)
                              PopupMenuItem(
                                value: sort,
                                child: Text(_sortLabel(sort)),
                              ),
                          ],
                          child: Chip(
                            avatar: const Icon(Icons.sort, size: 18),
                            label: Text(_sortLabel(state.sort)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${state.visible.length} doctors',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 6),
                    if (state.status == LoadStatus.empty)
                      StateMessage(
                        icon: Icons.search_off,
                        title: 'No doctors found',
                        message: data.doctors.isEmpty
                            ? 'The dataset currently contains no doctors.'
                            : 'Try another search or reset the filters.',
                        actionLabel: data.doctors.isEmpty
                            ? 'Reload'
                            : 'Reset filters',
                        onAction: data.doctors.isEmpty
                            ? () {
                                searchController.clear();
                                cubit.load();
                              }
                            : clearFilters,
                      )
                    else
                      for (final doctor in state.visible)
                        DoctorTile(
                          doctor: doctor,
                          favorite: state.favorites.contains(doctor.id),
                          onFavorite: () => cubit.toggleFavorite(doctor.id),
                          onOpen: () => openDetails(data, doctor),
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  String _sortLabel(DoctorSort sort) => switch (sort) {
    DoctorSort.nameAscending => 'Name A–Z',
    DoctorSort.nameDescending => 'Name Z–A',
    DoctorSort.nearest => 'Nearest',
  };
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.data, required this.onOpen});
  final Catalog data;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onOpen,
    borderRadius: BorderRadius.circular(10),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: turquoise,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.appointmentTitle,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              _line(Icons.calendar_month_outlined, data.appointmentDate),
              const SizedBox(height: 10),
              _line(Icons.access_time, data.appointmentTime),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Portrait(
                      asset: doctorAsset(data.appointmentDoctor),
                      size: 42,
                      radius: 7,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.appointmentDoctor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.appointmentDoctor.specialty,
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chat_outlined, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _line(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.white),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    ],
  );
}
