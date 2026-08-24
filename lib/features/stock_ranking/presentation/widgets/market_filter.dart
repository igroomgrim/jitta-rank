import 'package:flutter/material.dart';
import 'package:jitta_rank/core/theme/app_theme.dart';

class MarketFilter extends StatelessWidget {
  const MarketFilter({
    super.key,
    required this.selectedMarket,
    required this.onMarketSelected,
  });
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
              initialValue: selectedMarket,
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
          child: Text(
            'Cancel',
            style: TextStyle(color: context.semanticColors.negative),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'market': selectedMarket,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  /// Returns the display name for [marketCode], falling back to the code
  /// itself when it is not one of the known markets. Without the fallback this
  /// throws a StateError on any unrecognised code.
  static String getMarketName(String marketCode) {
    final market = MarketFilter.markets.firstWhere(
      (market) => market['code'] == marketCode,
      orElse: () => const {},
    );
    return market['name'] ?? marketCode;
  }
}
