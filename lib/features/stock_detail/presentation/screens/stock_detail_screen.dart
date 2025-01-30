import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';

class StockDetailScreen extends StatelessWidget {
  final int stockId;

  const StockDetailScreen({
    required this.stockId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockDetailBloc(GetStockDetailUsecase(
          StockDetailRepositoryImpl(
              StockDetailGraphqlDatasource(GraphqlService()),
              StockDetailLocalDatasourceImpl()))),
      child: _StockDetailView(stockId: stockId),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  final int stockId;

  const _StockDetailView({
    required this.stockId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Detail')),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<StockDetailBloc>()
              .add(RefreshStockDetailEvent(stockId));
        },
        child: BlocBuilder<StockDetailBloc, StockDetailState>(
          builder: (context, state) {
            if (state is StockDetailInitial) {
              context
                  .read<StockDetailBloc>()
                  .add(GetStockDetailEvent(stockId));
              return const Center(child: CircularProgressIndicator());
            } else if (state is StockDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StockDetailLoaded) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildStockDetail(state.stock),
                    ],
                  ),
                ),
              );
            } else if (state is StockDetailError) {
              return Center(
                  child: Text('Error loading stock detail ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

Widget _buildStockDetail(Stock stock) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${stock.symbol} - ${stock.name}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text(stock.nativeName, style: TextStyle(fontSize: 16)),
      Text('Jitta Rank Score: ${stock.jittaRankScore.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
      Text('Latest Price: ${stock.currencySign}${stock.price.close} ${stock.currency}', style: TextStyle(fontSize: 16)),
      _buildLatestPriceTimestamp(stock.price),
      Text('Jitta Score: ${stock.jitta.score.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
      Text('Jitta Total: ${stock.jitta.total}', style: TextStyle(fontSize: 16)),
      Text('Loss Chance: ${stock.lossChance.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
      Text('Sector: ${stock.sectorName}', style: TextStyle(fontSize: 16)),
      SizedBox(height: 16),
      _buildJittaFactor(stock.jitta.factor),
      SizedBox(height: 16),
      _buildSummary(stock.summary),
      SizedBox(height: 16),
      _buildGraphPrice(stock.graphPrice),
    ],
  );
}

Widget _buildLatestPriceTimestamp(StockPrice price) {
  return Text(
    'Latest Price Timestamp: ${price.latestPriceTimestamp != null ? price.latestPriceTimestamp.toString().split(' ')[0] : '-'}',
    style: TextStyle(fontSize: 16)
  );
}

Widget _buildJittaFactor(StockJittaFactor factor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Jitta Factor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text('Growth: ${factor.growth.value}', style: TextStyle(fontSize: 16)),
      Text('Financial: ${factor.financial.value}', style: TextStyle(fontSize: 16)),
      Text('Management: ${factor.management.value}', style: TextStyle(fontSize: 16)),
    ],
  );
}

Widget _buildSummary(String summary) {
  if (summary.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text(summary, style: TextStyle(fontSize: 16)),
    ],
  );
}

Widget _buildGraphPrice(StockGraphPrice graphPrice) {
  if (graphPrice.graphs.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Graph Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      Text('First Graph Period: ${graphPrice.firstGraphPeriod}', style: TextStyle(fontSize: 16)),
      // TODO: build graph
    ],
  );
}
