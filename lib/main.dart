import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/catalog_repository.dart';
import 'screens/home_screen.dart';
import 'state/doctors_cubit.dart';
import 'widgets/common.dart';

void main() => runApp(const DoctorApp());

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key, this.repository});
  final CatalogRepository? repository;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DoctorsCubit(repository ?? CatalogRepository())..load(),
    child: MaterialApp(
      title: 'Lab3 · Doctor Appointment',
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
  );
}
