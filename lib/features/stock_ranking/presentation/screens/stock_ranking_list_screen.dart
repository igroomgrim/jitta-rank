import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class StockRankingListScreen extends StatelessWidget {
  const StockRankingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Ranking'),
      ),
      body: BlocProvider(
        create: (context) => StockRankingsBloc(GetStockRankingsUsecase(StockRankingRepositoryImpl())),
        child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
          builder: (context, state) {
            if (state is StockRankingsInitial) {
              context.read<StockRankingsBloc>().add(GetStockRankingsEvent());
              return const Center(child: CircularProgressIndicator());
            } else if (state is StockRankingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StockRankingsLoaded) {
              return _buildStockRankingList(state.rankedStocks);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ); // Scaffold
  }

  Widget _buildStockRankingList(List<RankedStock> rankedStocks) {
    return ListView.builder(
      itemCount: rankedStocks.length,
      itemBuilder: (context, index) {
        return _buildStockRankingItem(rankedStocks[index]);
      },
    );
  }

  Widget _buildStockRankingItem(RankedStock rankedStock) {
    return ListTile(
      title: Text(rankedStock.title),
      subtitle: Text('${rankedStock.symbol} - ${rankedStock.latestPrice}'),
    );
  }
}
