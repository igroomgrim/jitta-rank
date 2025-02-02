import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/debounced_search_field.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/sector_filter.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/market_filter.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';

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
      create: (context) => context.read<NetworkInfoBloc>(),
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
                    "${MarketFilter.getMarketName(state.market)} Stock Rankings",
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
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
                    builder: (context, state) {
                      return DebouncedSearchField(
                        hintText: 'Search by symbol or title...',
                        onSearch: (searchFieldValue) {
                          context.read<StockRankingsBloc>().add(
                              FilterStockRankingsEvent(
                                  searchFieldValue: searchFieldValue,
                                  market: state.market,
                                  sectors: state.sectors));
                        },
                      );
                    },
                  ),
                ),
                BlocBuilder<StockRankingsBloc, StockRankingsState>(
                  builder: (context, state) {
                    return SectorFilter(
                      selectedSectors: state.sectors,
                      onSectorSelected: (sector) {
                        final sectors = state.sectors.contains(sector)
                            ? state.sectors.where((s) => s != sector).toList()
                            : [...state.sectors, sector];
                        context.read<StockRankingsBloc>().add(
                            FilterStockRankingsEvent(
                                market: state.market,
                                sectors: sectors,
                                searchFieldValue: state.searchFieldValue));
                      },
                    );
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
                Navigator.pushNamed(context, AppRouter.stockDetailScreen,
                    arguments: state.stockId);
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
                                      market: state.market,
                                      sectors: state.sectors));
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
          ),
        ),
      ),
    );
  }

  Widget _buildStockRankingList(
      BuildContext context, StockRankingsLoaded state) {
    if (state.rankedStocks.isEmpty) {
      return const Center(child: Text("No stocks found!"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (state.searchFieldValue.isEmpty) {
          context.read<StockRankingsBloc>().add(PullToRefreshStockRankingsEvent(
              market: state.market, sectors: state.sectors));
        }
        _checkInternetConnection();
      },
      notificationPredicate: (ScrollNotification scrollInfo) {
        return state.searchFieldValue.isEmpty;
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
                page: nextPage, market: state.market, sectors: state.sectors));
            return const Center(child: CircularProgressIndicator());
          }

          return _buildStockRankingItem(context, state.rankedStocks[index]);
        },
      ),
    );
  }

  Widget _buildStockRankingItem(BuildContext context, RankedStock rankedStock) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          context
              .read<NavigationCubit>()
              .navigateToStockDetailScreen(rankedStock.stockId);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol + Title and Price part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: rankedStock.symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' - ${rankedStock.title}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${rankedStock.currency}${rankedStock.latestPrice}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Jitta Score part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jitta Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    rankedStock.jittaScore.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Market part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    rankedStock.market ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Sector part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sector',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rankedStock.sector?.name ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Market filter dialog
  void _showMarketFilterDialog(BuildContext context) {
    final bloc = context.read<StockRankingsBloc>();

    showDialog<Map<String, String>>(
      context: context,
      builder: (context) => MarketFilter(
          selectedMarket: bloc.state.market,
          onMarketSelected: (market) {
            Navigator.pop(context, {
              'market': market,
            });
          }),
    ).then((result) {
      if (result != null && mounted) {
        final market = result['market'] ?? ApiConstants.defaultMarket;
        bloc.add(FilterStockRankingsEvent(
            searchFieldValue: bloc.state.searchFieldValue,
            market: market,
            sectors: bloc.state.sectors));
      }
    });
  }
}
