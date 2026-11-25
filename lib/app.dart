import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/repositories/doctors_repository.dart';
import 'domain/usecases/get_doctors.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/state/doctors_cubit.dart';
import 'presentation/widgets/common.dart';

// Dependency composition is external: presentation receives a domain contract.
class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key, required this.repository});
  final DoctorsRepository repository;
  @override
  Widget build(BuildContext context) => RepositoryProvider(
    create: (_) => GetAppointmentDetails(repository),
    child: BlocProvider(
      create: (_) => DoctorsCubit(GetDoctors(repository))..load(),
      child: MaterialApp(
        title: 'Lab4 · Doctor Appointment',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          textTheme: const TextTheme(bodyMedium: TextStyle(color: ink)),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    ),
  );
}
