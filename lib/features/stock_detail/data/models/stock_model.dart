import 'package:jitta_rank/features/stock_detail/domain/entities/stock.dart';

class StockModel extends Stock {
  StockModel({
    required super.id,
    required super.stockId,
    required super.currency,
    required super.currencySign,
    required super.title,
    required super.symbol,
    required super.summary,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id']?.toString() ?? '',
      stockId: json['stockId']?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? '',
      currencySign: json['currency_sign']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}
