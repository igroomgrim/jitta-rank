import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/networking/graphql_service.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';

class StockRankingListScreen extends StatelessWidget {
  const StockRankingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Ranking'),
      ),
      body: BlocProvider(
        create: (context) => StockRankingsBloc(GetStockRankingsUsecase(StockRankingRepositoryImpl(StockRankingGraphqlDatasource(GraphqlService())))),
        child: BlocListener<NavigationCubit, NavigationState?>(
          listener: (context, state) {
            if (state is NavigateToStockDetailScreen) {
              Navigator.pushNamed(context, AppRouter.stockDetailScreen, arguments: state.stockId);
            }
            context.read<NavigationCubit>().resetNavigation();
          },
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
      ),
    ); // Scaffold
  }

  Widget _buildStockRankingList(List<RankedStock> rankedStocks) {
    return ListView.builder(
      itemCount: rankedStocks.length,
      itemBuilder: (context, index) {
        return _buildStockRankingItem(context, rankedStocks[index]);
      },
    );
  }

  Widget _buildStockRankingItem(BuildContext context, RankedStock rankedStock) {
    return ListTile(
        title: Text('${rankedStock.symbol} - ${rankedStock.title}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jitta Score: ${rankedStock.jittaScore}'),
          Text('Latest Price: ${rankedStock.currency}${rankedStock.latestPrice}'),
        ],
      ),
      onTap: () {
          context.read<NavigationCubit>().navigateToStockDetailScreen(rankedStock.stockId);
      },
    );
  }
}
