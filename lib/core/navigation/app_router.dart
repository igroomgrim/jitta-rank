import 'package:flutter/material.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/screens/stock_ranking_list_screen.dart';
import 'package:jitta_rank/features/stock_detail/presentation/screens/stock_detail_screen.dart';

class AppRouter {
  static const stockRankingListScreen = '/';
  static const stockDetailScreen = '/stock-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case stockRankingListScreen:
        return MaterialPageRoute(
            builder: (_) => const StockRankingListScreen());
      case stockDetailScreen:
        final stockId = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => StockDetailScreen(stockId: stockId));
      default:
        return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}
