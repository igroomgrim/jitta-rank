class ApiConstants {
  /// GraphQL endpoint.
  ///
  /// Override per environment without touching source:
  /// `flutter run --dart-define=API_BASE_URL=https://example.com/`
  ///
  /// Defaults to Jitta's public staging endpoint so a fresh clone runs with
  /// no configuration.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://thecollector-staging-l6chkvtlsa-df.a.run.app/',
  );

  static const String defaultMarket = 'TH';
  static const int defaultLimit = 20;
  static const int defaultPage = 1;
  static const List<String> defaultSectors = [];
}
