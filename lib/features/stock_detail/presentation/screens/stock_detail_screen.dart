import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StockDetailScreen extends StatelessWidget {
  final int stockId;

  const StockDetailScreen({
    required this.stockId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final networkInfoService = NetworkInfoServiceImpl();

    return BlocProvider(
      create: (context) => StockDetailBloc(GetStockDetailUsecase(
          StockDetailRepositoryImpl(
              StockDetailGraphqlDatasource(GraphqlService()),
              StockDetailLocalDatasourceImpl(),
              networkInfoService))),
      // TODO: Should be injected or use provider at app level?
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
          context.read<StockDetailBloc>().add(RefreshStockDetailEvent(stockId));
        },
        color: Colors.blue,
        child: BlocBuilder<StockDetailBloc, StockDetailState>(
          builder: (context, state) {
            if (state is StockDetailInitial) {
              context.read<StockDetailBloc>().add(GetStockDetailEvent(stockId));
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            } else if (state is StockDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            } else if (state is StockDetailLoaded) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStockDetail(state.stock),
                    ],
                  ),
                ),
              );
            } else if (state is StockDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(state.message, textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<StockDetailBloc>()
                            .add(RefreshStockDetailEvent(stockId));
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
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
      _buildHeader(stock),
      const SizedBox(height: 4),
      _buildJittaCard(stock, stock.jitta.factor),
      const SizedBox(height: 4),
      _buildGraphPrice(stock.graphPrice),
      const SizedBox(height: 4),
      if (stock.summary.isNotEmpty) _buildSummary(stock.summary),
      SizedBox(height: 16),
    ],
  );
}

Widget _buildHeader(Stock stock) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.symbol,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            stock.name,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${stock.currencySign}${stock.price.close}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stock.currency,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLatestPriceTimestamp(stock.price),
        ],
      ),
    ),
  );
}

Widget _buildJittaCard(Stock stock, StockJittaFactor factor) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jitta Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          MetricRow('Jitta Score', stock.jitta.score.toStringAsFixed(2)),
          MetricRow(
              'Jitta Rank Score', stock.jittaRankScore.toStringAsFixed(2)),
          MetricRow('Jitta Total', stock.jitta.total.toString()),
          MetricRow('Loss Chance', '${stock.lossChance.toStringAsFixed(2)}%'),
          const SizedBox(height: 12),
          const Text(
            'Jitta Factor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          MetricRow('Growth', factor.growth.value.toString()),
          MetricRow('Financial', factor.financial.value.toString()),
          MetricRow('Management', factor.management.value.toString()),
          const SizedBox(height: 12),
          const Text(
            'Market Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          MetricRow('Market', stock.market),
          MetricRow('Sector', stock.sectorName),
        ],
      ),
    ),
  );
}

Widget _buildGraphPrice(StockGraphPrice graphPrice) {
  if (graphPrice.graphs.isEmpty) return const SizedBox.shrink();

  final filteredGraphs = graphPrice.graphs
      .where((graph) => graph.linePrice != 0 && graph.stockPrice != 0)
      .toList();
  final linePrices = filteredGraphs.map((graph) => graph.linePrice).toList();
  final stockPrices = filteredGraphs.map((graph) => graph.stockPrice).toList();
  final yAxisLabelInterval = linePrices.length / 2;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Graph Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                  backgroundColor: Colors.white,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: yAxisLabelInterval,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(value.toStringAsFixed(1),
                                style: TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          linePrices.length,
                          (index) =>
                              FlSpot(index.toDouble(), linePrices[index])),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: List.generate(
                          stockPrices.length,
                          (index) =>
                              FlSpot(index.toDouble(), stockPrices[index])),
                      isCurved: true,
                      color: Colors.redAccent,
                      dotData: FlDotData(show: false),
                    ),
                  ]),
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: 'Stock Price',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
                TextSpan(
                    text: ', ',
                    style: TextStyle(color: Colors.black, fontSize: 12)),
                TextSpan(
                    text: 'Line Price',
                    style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
          Text('Most recent ${filteredGraphs.length} price entries',
              style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

Widget _buildSummary(String summary) {
  if (summary.isEmpty) return const SizedBox.shrink();
  return Card(
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(summary, style: TextStyle(fontSize: 16)),
            ],
          )));
}

class MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const MetricRow(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLatestPriceTimestamp(StockPrice price) {
  return Text(
      'Latest Price Timestamp: ${price.latestPriceTimestamp != null ? price.latestPriceTimestamp.toString().split(' ')[0] : '-'}',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]));
}
