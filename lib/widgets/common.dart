import 'package:flutter/material.dart';

import '../models/catalog.dart';

const teal = Color(0xFF0991AD);
const turquoise = Color(0xFF27ABBD);
const ink = Color(0xFF191D35);
const muted = Color(0xFF85899A);

// Explicit local equivalents preserve the lab2 design; URLs remain in the JSON.
String doctorAsset(Doctor doctor) => switch (doctor.id) {
  'doctor-001' => 'emmly',
  'doctor-002' => 'sonja',
  'home-appointment' => 'richar',
  'appointment-doctor' => 'upul',
  _ => '',
};

class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    required this.asset,
    this.size = 48,
    this.radius = 50,
  });
  final String asset;
  final double size, radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$asset.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: const Color(0xFFD8EEEA),
        child: const Icon(Icons.person_outline, color: teal),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title, {
    super.key,
    this.action,
    this.actionLabel = 'See All',
  });
  final String title, actionLabel;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      if (action != null)
        TextButton(onPressed: action, child: Text(actionLabel)),
    ],
  );
}

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String title, message, actionLabel;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 38, color: teal),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    ),
  );
}

class DoctorTile extends StatelessWidget {
  const DoctorTile({
    super.key,
    required this.doctor,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
  });
  final Doctor doctor;
  final bool favorite;
  final VoidCallback onFavorite, onOpen;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Portrait(asset: doctorAsset(doctor)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: turquoise,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                doctor.distance,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          key: ValueKey('favorite-${doctor.id}'),
          tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onFavorite,
          icon: Icon(
            favorite ? Icons.favorite : Icons.favorite_border,
            color: favorite ? teal : muted,
            size: 22,
          ),
        ),
      ],
    ),
  );
}

class SlotSelector extends StatelessWidget {
  const SlotSelector({
    super.key,
    required this.group,
    required this.selected,
    required this.onSelect,
  });
  final SlotGroup group;
  final String? selected;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(group.title),
      const SizedBox(height: 16),
      if (group.slots.isEmpty)
        const Text('No slots available', style: TextStyle(color: muted)),
      Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          for (final slot in group.slots)
            ChoiceChip(
              label: Text(slot.label),
              selected: selected == slot.id,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              selectedColor: teal,
              backgroundColor: const Color(0xFFF4F4F4),
              side: BorderSide.none,
              labelStyle: TextStyle(
                fontSize: 16,
                color: selected == slot.id ? Colors.white : ink,
              ),
              onSelected: (_) => onSelect(slot.id),
            ),
        ],
      ),
    ],
  );
}
