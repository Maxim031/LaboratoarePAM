import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const ink = Color(0xFF191D35);
const muted = Color(0xFF8B8D9C);
const turquoise = Color(0xFF27ABBD);
const teal = Color(0xFF0991AD);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Doctor Appointment',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: ink)),
      splashFactory: NoSplash.splashFactory,
    ),
    home: const HomeScreen(),
  );
}

// Keep the reference proportions on different phone widths. Small screens scroll.
class ReferencePage extends StatelessWidget {
  const ReferencePage({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });
  final double width, height;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / width;
          return SingleChildScrollView(
            child: SizedBox(
              width: constraints.maxWidth,
              height: math.max(height * scale, constraints.maxHeight),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: height * scale,
                  child: FittedBox(
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fill,
                    child: SizedBox(width: width, height: height, child: child),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget photo(String name, double size, {double radius = 50}) => ClipRRect(
  borderRadius: BorderRadius.circular(radius),
  child: Image.asset(
    'assets/images/$name.png',
    width: size,
    height: size,
    fit: BoxFit.cover,
    filterQuality: FilterQuality.high,
  ),
);

Widget label(
  String value,
  double size, {
  Color color = ink,
  FontWeight weight = FontWeight.normal,
}) => Text(
  value,
  style: TextStyle(fontSize: size, color: color, fontWeight: weight),
);

void openAppointment(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (_) => const AppointmentDetailsScreen()),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => ReferencePage(
    width: 329,
    height: 674,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 27),
          Row(
            children: [
              photo('jonathan', 39),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label('Hi, Jonathan', 12, weight: FontWeight.w600),
                  const SizedBox(height: 3),
                  label('May you always be healthy', 8, color: muted),
                ],
              ),
              const Spacer(),
              const SizedBox(
                width: 29,
                height: 30,
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 0,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: ink,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 13,
                      child: CircleAvatar(
                        radius: 3.5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Container(
            height: 47,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search, size: 24, color: Color(0xFFA1ABC5)),
                const SizedBox(width: 10),
                label('Search something', 12, color: const Color(0xFFA1ABC5)),
                const Spacer(),
                const Icon(Icons.tune, size: 22, color: Color(0xFFA1ABC5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => openAppointment(context),
            child: SizedBox(
              height: 174,
              child: Stack(
                children: [
                  Container(
                    height: 152,
                    decoration: BoxDecoration(
                      color: turquoise,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: const EdgeInsets.all(19),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            label('Appointment', 10, color: Colors.white),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_calendar_outlined,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 7),
                            label(
                              '22 October, 2023',
                              12,
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            label(
                              '08:00 AM - 10.30 AM',
                              12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 19,
                    top: 60,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.edit_square,
                        color: turquoise,
                        size: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 19,
                    right: 19,
                    top: 115,
                    child: Container(
                      height: 59,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .06),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          photo('richar', 37, radius: 6),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(
                                  'Dr. Richar Kandowen',
                                  13,
                                  weight: FontWeight.w600,
                                ),
                                const SizedBox(height: 4),
                                label('Child Specialist', 10, color: muted),
                              ],
                            ),
                          ),
                          const Icon(Icons.chat_outlined, color: ink, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _heading('Health Services'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final item in ['Tooth', 'Eye', 'Lungs', 'Ear'])
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/${item.toLowerCase()}.png',
                        width: 36,
                        height: 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    label(item, 12, color: muted),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 22),
          _heading('Nearby Doctor'),
          const SizedBox(height: 14),
          const NearbyDoctorCard(
            name: 'Dr. Emmly Lestiryno',
            specialty: 'General Practitioner',
            location: '3167 Durgan Shores - 500M from you',
            image: 'emmly',
          ),
          const SizedBox(height: 16),
          const NearbyDoctorCard(
            name: 'Dr. Sonja Littel',
            specialty: 'Dental Specialist',
            location: '950 Sigrid Port - 753M from you',
            image: 'sonja',
          ),
        ],
      ),
    ),
  );

  Widget _heading(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      label(title, 15, weight: FontWeight.w600),
      label('See All', 10, color: turquoise),
    ],
  );
}

class NearbyDoctorCard extends StatefulWidget {
  const NearbyDoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.location,
    required this.image,
  });
  final String name, specialty, location, image;
  @override
  State<NearbyDoctorCard> createState() => _NearbyDoctorCardState();
}

class _NearbyDoctorCardState extends State<NearbyDoctorCard> {
  bool favorite = false;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 60,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => openAppointment(context),
          child: photo(widget.image, 40),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: GestureDetector(
            onTap: () => openAppointment(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label(widget.name, 12, weight: FontWeight.w600),
                const SizedBox(height: 4),
                label(widget.specialty, 10, color: muted),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: turquoise, size: 15),
                    const SizedBox(width: 4),
                    label(widget.location, 10),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => favorite = !favorite),
          child: Icon(
            favorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: favorite ? turquoise : muted,
          ),
        ),
      ],
    ),
  );
}

class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({super.key});
  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  String selectedTime = '11.00 AM', selectedDate = 'Sun 4';
  @override
  Widget build(BuildContext context) => ReferencePage(
    width: 377,
    height: 777,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: label(
                    'Appointment',
                    24,
                    color: teal,
                    weight: FontWeight.bold,
                  ),
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 23,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              photo('upul', 116, radius: 9),
              const SizedBox(width: 19),
              Expanded(
                child: SizedBox(
                  height: 116,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          label(
                            'Dr.Upul',
                            20,
                            color: Colors.black,
                            weight: FontWeight.bold,
                          ),
                          const Spacer(),
                          _action(Icons.chat_bubble_outline),
                          const SizedBox(width: 15),
                          _action(Icons.phone_outlined),
                          const SizedBox(width: 15),
                          _action(Icons.videocam_outlined),
                        ],
                      ),
                      const SizedBox(height: 8),
                      label('Denteeth', 15, color: const Color(0xFF6AC4BA)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          label(
                            'Payment',
                            18,
                            color: Colors.black,
                            weight: FontWeight.w500,
                          ),
                          label(
                            '\$120.00',
                            18,
                            color: const Color(0xFF6AC4BA),
                            weight: FontWeight.bold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 37),
          label('Details', 20, color: Colors.black, weight: FontWeight.w500),
          const SizedBox(height: 11),
          const Text(
            'Worem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur tempus urna at turpis condimentum lobortis. Ut commodo efficitur neque. Ut diam quam, semper iaculis condimentum ac, vestibulum eu nisl.',
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              color: Color(0xFF929292),
            ),
          ),
          const SizedBox(height: 51),
          _heading('Working Hours'),
          const SizedBox(height: 19),
          _slots(
            ['10.00 AM', '11.00 AM', '12.00 PM'],
            selectedTime,
            (value) => setState(() => selectedTime = value),
          ),
          const SizedBox(height: 23),
          _heading('Date'),
          const SizedBox(height: 19),
          _slots(
            ['Sun 4', 'Mon 5', 'Tue 6'],
            selectedDate,
            (value) => setState(() => selectedDate = value),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Appointment booked: $selectedDate, $selectedTime',
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Book an Appointment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 35),
        ],
      ),
    ),
  );

  Widget _action(IconData icon) => CircleAvatar(
    radius: 13,
    backgroundColor: const Color(0xFFD8EEEA),
    child: Icon(icon, size: 15, color: const Color(0xFF193B3B)),
  );
  Widget _heading(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      label(title, 20, color: Colors.black, weight: FontWeight.w500),
      label('See All', 14, color: Colors.black),
    ],
  );
  Widget _slots(
    List<String> values,
    String selected,
    ValueChanged<String> onSelect,
  ) => Row(
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0) const SizedBox(width: 13),
        Expanded(
          child: GestureDetector(
            onTap: () => onSelect(values[i]),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == values[i] ? teal : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: label(
                values[i],
                18,
                color: selected == values[i] ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
