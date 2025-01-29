import 'package:flutter/material.dart';

class SectorFilter extends StatelessWidget {
  static const List<Map<String, String>> sectors = [ // note: seems like always 11 sectors
    {'id': 'ENERGY', 'name': 'Energy'},
    {'id': 'FINANCIALS', 'name': 'Financials'},
    {'id': 'HEALTHCARE', 'name': 'Healthcare'},
    {'id': 'INDUSTRIALS', 'name': 'Industrials'},
    {'id': 'INFORMATION_TECHNOLOGY', 'name': 'Information technology'},
    {'id': 'MATERIALS', 'name': 'Materials'},
    {'id': 'REAL_ESTATE', 'name': 'Real estate'},
    {'id': 'TELECOMMUNICATION_SERVICES', 'name': 'Communication services'},
    {'id': 'UTILITIES', 'name': 'Utilities'},
    {'id': 'CONSUMER_DISCRETIONARY', 'name': 'Consumer discretionary'},
    {'id': 'CONSUMER_STAPLES', 'name': 'Consumer staples'},
  ];

  final List<String> selectedSectors;
  final Function(String) onSectorSelected;

  const SectorFilter({
    super.key,
    required this.selectedSectors,
    required this.onSectorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            ...sectors.map((sector) {
              final isSelected = selectedSectors.contains(sector['id']);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(sector['name']!),
                  onSelected: (bool selected) {
                    onSectorSelected(sector['id']!);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}