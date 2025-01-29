import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/debounced_search_field.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/sector_filter.dart';

class StockRankingListScreen extends StatefulWidget {
  const StockRankingListScreen({super.key});

  @override
  State<StockRankingListScreen> createState() => _StockRankingListScreenState();
}

class _StockRankingListScreenState extends State<StockRankingListScreen> {
  List<String> _selectedSectors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Ranking'),
        actions: [
          IconButton(
            onPressed: () {
              print('Filter Button Pressed');
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: [
              DebouncedSearchField(
                hintText: 'Search by symbol or title...',
                onSearch: (query) {
              if (query.isEmpty) {
                context.read<StockRankingsBloc>().add(GetStockRankingsEvent());
              } else {
                    context.read<StockRankingsBloc>().add(SearchStockRankingsEvent(query));
                  }
                },
              ),
              SectorFilter(
                selectedSectors: _selectedSectors,
                onSectorSelected: (sector) {
                  setState(() {
                    if (_selectedSectors.contains(sector)) {
                      _selectedSectors.remove(sector);
                    } else {
                      _selectedSectors.add(sector);
                    }
                  });

                  context.read<StockRankingsBloc>().add(ClearLoadedStockRankingsEvent());
                  context.read<StockRankingsBloc>().add(GetStockRankingsEvent(sectors: _selectedSectors));
                },
              ),
            ],
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => context.read<StockRankingsBloc>(),
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
                  return _buildStockRankingList(context, state);
                } else if (state is StockRankingsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StockRankingsBloc>().add(RefreshStockRankingsEvent());
                          },
                          child: const Text('Reload Stocks'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
  }

  Widget _buildStockRankingList(BuildContext context, StockRankingsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StockRankingsBloc>().add(RefreshStockRankingsEvent());
      },
      child: ListView.builder(
        itemCount: state.rankedStocks.length + (state.hasReachedMaxData ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.rankedStocks.length) {
            final nextPage = (state.rankedStocks.length ~/ ApiConstants.defaultLoadLimit) + 1; // TODO: Should calculate max next page from count
            context.read<StockRankingsBloc>().add(
              GetStockRankingsEvent(page: nextPage)
            );
            return const Center(child: CircularProgressIndicator());
          }

          return _buildStockRankingItem(context, state.rankedStocks[index]);
        },
      ),
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
          Text('Sector: ${rankedStock.sector?.name}'),
        ],
      ),
      onTap: () {
          context.read<NavigationCubit>().navigateToStockDetailScreen(rankedStock.stockId);
      },
    );
  }
}
