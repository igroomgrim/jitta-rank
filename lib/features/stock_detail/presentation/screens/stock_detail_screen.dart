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
              StockDetailGraphqlDatasource(GraphqlService())))),
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
              return const Center(
                  child: Text('Error loading stock detail'));
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
      Text('${stock.symbol} - ${stock.title}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text(stock.summary, style: TextStyle(fontSize: 16)),
      SizedBox(height: 20),
    ],
  );
}
