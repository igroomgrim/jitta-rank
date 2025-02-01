import 'package:flutter/material.dart';

class MarketFilter extends StatelessWidget {
  static const List<Map<String, String>> markets = [
    {'code': 'TH', 'name': 'Thailand'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'SG', 'name': 'Singapore'},
    {'code': 'VN', 'name': 'Vietnam'},
    {'code': 'HK', 'name': 'Hong Kong'},
    {'code': 'UK', 'name': 'United Kingdom'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'CN', 'name': 'China'},
    {'code': 'TW', 'name': 'Taiwan'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'RU', 'name': 'Russia'},
  ];

  final String selectedMarket;
  final Function(String) onMarketSelected;

  const MarketFilter(
      {super.key,
      required this.selectedMarket,
      required this.onMarketSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Stocks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Market', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMarket,
              isExpanded: true,
              items: MarketFilter.markets.map((market) {
                return DropdownMenuItem(
                  value: market['code'],
                  child: Text(market['name']!),
                );
              }).toList(),
              onChanged: (value) {
                onMarketSelected(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'market': selectedMarket,
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.blue),
          ),
          child: const Text('Apply', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  static String getMarketName(String marketCode) {
    return MarketFilter.markets
        .firstWhere((market) => market['code'] == marketCode)['name']!;
  }
}
