import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/di/injection_container.dart';
import 'package:jitta_rank/core/theme/app_theme.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({required this.stockId, super.key});

  final int stockId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockDetailBloc>(),
      child: StockDetailView(stockId: stockId),
    );
  }
}

/// The screen's actual content, split out from the DI wrapper so widget tests
/// can provide a mock bloc instead of standing up the whole container.
class StockDetailView extends StatefulWidget {
  const StockDetailView({required this.stockId, super.key});

  final int stockId;

  @override
  State<StockDetailView> createState() => _StockDetailViewState();
}

class _StockDetailViewState extends State<StockDetailView> {
  @override
  void initState() {
    super.initState();
    // Dispatched here, not from BlocBuilder's builder. The old code fired
    // GetStockDetailEvent whenever it observed the Initial state during build.
    context.read<StockDetailBloc>().add(GetStockDetailEvent(widget.stockId));
  }

  void _refresh() => context.read<StockDetailBloc>().add(
        RefreshStockDetailEvent(widget.stockId),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Detail')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: BlocBuilder<StockDetailBloc, StockDetailState>(
          builder: (context, state) {
            if (state.hasFailedWithNoData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            final stock = state.stock;
            if (stock == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // A failed refresh keeps the previously loaded stock on screen and
            // reports the failure above it rather than blanking the page.
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.hasFailed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          state.errorMessage ?? 'Could not refresh',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _buildStockDetail(context, stock),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildStockDetail(BuildContext context, Stock stock) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(context, stock),
      const SizedBox(height: 4),
      _buildJittaCard(context, stock, stock.jitta.factor),
      const SizedBox(height: 4),
      _buildGraphPrice(context, stock.graphPrice),
      const SizedBox(height: 4),
      if (stock.summary.isNotEmpty) _buildSummary(stock.summary),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildHeader(BuildContext context, Stock stock) {
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
            style:
                TextStyle(fontSize: 14, color: context.colors.onSurfaceVariant),
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.semanticColors.positive,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                stock.currency,
                style: TextStyle(
                  fontSize: 24,
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLatestPriceTimestamp(context, stock.price),
        ],
      ),
    ),
  );
}

Widget _buildJittaCard(
  BuildContext context,
  Stock stock,
  StockJittaFactor factor,
) {
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
            'Jitta Rank Score',
            stock.jittaRankScore.toStringAsFixed(2),
          ),
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

Widget _buildGraphPrice(BuildContext context, StockGraphPrice graphPrice) {
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
          const Text(
            'Graph Price',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                backgroundColor: context.colors.surface,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
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
                          child: Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      linePrices.length,
                      (index) => FlSpot(index.toDouble(), linePrices[index]),
                    ),
                    isCurved: true,
                    color: context.semanticColors.positive,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      stockPrices.length,
                      (index) => FlSpot(index.toDouble(), stockPrices[index]),
                    ),
                    isCurved: true,
                    color: context.semanticColors.negative,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Stock Price',
                  style: TextStyle(
                    color: context.semanticColors.negative,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: ', ',
                  style:
                      TextStyle(color: context.colors.onSurface, fontSize: 12),
                ),
                TextSpan(
                  text: 'Line Price',
                  style: TextStyle(
                    color: context.semanticColors.positive,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Most recent ${filteredGraphs.length} price entries',
            style: const TextStyle(fontSize: 12),
          ),
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
          const Text(
            'Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(summary, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

class MetricRow extends StatelessWidget {
  const MetricRow(this.label, this.value, {super.key});
  final String label;
  final String value;

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
              color: context.colors.onSurfaceVariant,
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

Widget _buildLatestPriceTimestamp(BuildContext context, StockPrice price) {
  return Text(
    'Latest Price Timestamp: ${price.latestPriceTimestamp != null ? price.latestPriceTimestamp.toString().split(' ')[0] : '-'}',
    style: TextStyle(fontSize: 14, color: context.colors.onSurfaceVariant),
  );
}
