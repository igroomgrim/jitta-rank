import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';
import 'package:jitta_rank/core/di/injection_container.dart';

class StockRankingListScreen extends StatefulWidget {
  const StockRankingListScreen({super.key});

  @override
  State<StockRankingListScreen> createState() => _StockRankingListScreenState();
}

class _StockRankingListScreenState extends State<StockRankingListScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  void _checkInternetConnection() {
    context.read<NetworkInfoBloc>().add(CheckConnectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StockRankingsBloc>(),
      child: Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                BlocBuilder<StockRankingsBloc, StockRankingsState>(
                  builder: (context, state) {
                    return Text(
                      "${MarketFilter.getMarketName(state.filter.market)} Stock Rankings",
                    );
                  },
                ),
                BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
                  builder: (context, state) {
                    return Text(
                      state.isConnected
                          ? 'Online Mode'
                          : 'Offline Mode - Showing cached data',
                      style: TextStyle(
                          fontSize: 10,
                          color: state.isConnected ? Colors.blue : Colors.red),
                    );
                  },
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  _showMarketFilterDialog(context);
                },
                icon: Icon(Icons.filter_list),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(112),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                    child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
                      builder: (context, state) {
                        return DebouncedSearchField(
                          hintText: 'Search by symbol or title...',
                          onSearch: (searchFieldValue) {
                            context.read<StockRankingsBloc>().add(
                                FilterStockRankingsEvent(
                                    searchFieldValue: searchFieldValue,
                                    market: state.filter.market,
                                    sectors: state.filter.sectors));
                          },
                        );
                      },
                    ),
                  ),
                  BlocBuilder<StockRankingsBloc, StockRankingsState>(
                    builder: (context, state) {
                      return SectorFilter(
                        selectedSectors: state.filter.sectors,
                        onSectorSelected: (sector) {
                          final sectors = state.filter.sectors.contains(sector)
                              ? state.filter.sectors
                                  .where((s) => s != sector)
                                  .toList()
                              : [...state.filter.sectors, sector];
                          context.read<StockRankingsBloc>().add(
                              FilterStockRankingsEvent(
                                  market: state.filter.market,
                                  sectors: sectors,
                                  searchFieldValue:
                                      state.filter.searchFieldValue));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: BlocListener<NavigationCubit, NavigationState?>(
            listener: (context, state) {
              if (state is NavigateToStockDetailScreen) {
                Navigator.pushNamed(context, AppRouter.stockDetailScreen,
                    arguments: state.stockId);
                context.read<NavigationCubit>().resetNavigation();
              }
            },
            child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
              builder: (context, state) {
                switch (state) {
                  case StockRankingsInitial _:
                    context
                        .read<StockRankingsBloc>()
                        .add(GetStockRankingsEvent());
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.blue));

                  case StockRankingsLoading _:
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.blue));

                  case StockRankingsLoaded _:
                    return _buildStockRankingList(context, state);

                  case StockRankingsError _:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(state.message,
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StockRankingsBloc>().add(
                                  GetStockRankingsEvent(
                                      market: state.filter.market,
                                      sectors: state.filter.sectors));
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );

                  default:
                    return const Center(
                        child: Text("Oops! Something went wrong!"));
                }
              },
            ),
          )),
    );
  }

  Widget _buildStockRankingList(
      BuildContext context, StockRankingsLoaded state) {
    if (state.rankedStocks.isEmpty) {
      return const Center(child: Text("No stocks found!"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (state.filter.searchFieldValue.isEmpty) {
          context.read<StockRankingsBloc>().add(PullToRefreshStockRankingsEvent(
              market: state.filter.market, sectors: state.filter.sectors));
        }
        _checkInternetConnection();
      },
      notificationPredicate: (ScrollNotification scrollInfo) {
        return state.filter.searchFieldValue.isEmpty;
      },
      color: Colors.blue,
      child: ListView.builder(
        itemCount:
            state.rankedStocks.length + (state.hasReachedMaxData ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.rankedStocks.length &&
              state.rankedStocks.isNotEmpty) {
            final nextPage =
                (state.rankedStocks.length ~/ ApiConstants.defaultLimit) +
                    1; // TODO: Should calculate max next page from count
            context.read<StockRankingsBloc>().add(LoadMoreStockRankingsEvent(
                page: nextPage,
                market: state.filter.market,
                sectors: state.filter.sectors));
            return const Center(child: CircularProgressIndicator());
          }

          return StockRankingItem(
            rankedStock: state.rankedStocks[index],
            onTap: (rankedStock) {
              context
                  .read<NavigationCubit>()
                  .navigateToStockDetailScreen(rankedStock.stockId);
            },
          );
        },
      ),
    );
  }

  // Market filter dialog
  void _showMarketFilterDialog(BuildContext context) {
    final bloc = getIt<StockRankingsBloc>();

    showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: MarketFilter(
          selectedMarket: bloc.state.filter.market,
          onMarketSelected: (market) {
            Navigator.pop(dialogContext, {
              'market': market,
            });
          },
        ),
      ),
    ).then((result) {
      if (result != null && mounted) {
        final market = result['market'] ?? ApiConstants.defaultMarket;
        bloc.add(FilterStockRankingsEvent(
            searchFieldValue: bloc.state.filter.searchFieldValue,
            market: market,
            sectors: bloc.state.filter.sectors));
      }
    });
  }
}
