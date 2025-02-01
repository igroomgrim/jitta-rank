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
  List<String> _selectedSectors = [];
  String _selectedMarket = ApiConstants.defaultMarket;
  String _currentSearchFieldValue = '';

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              '${MarketFilter.getMarketName(_selectedMarket)} Stock Rankings',
              textAlign: TextAlign.center,
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
                child: DebouncedSearchField(
                  hintText: 'Search by symbol or title...',
                  onSearch: (searchFieldValue) {
                    setState(() {
                      _currentSearchFieldValue = searchFieldValue;
                    });

                    if (searchFieldValue.isEmpty) {
                      context.read<StockRankingsBloc>().add(
                          GetStockRankingsEvent(
                              market: _selectedMarket,
                              sectors: _selectedSectors));
                    } else {
                      context
                          .read<StockRankingsBloc>()
                          .add(SearchStockRankingsEvent(
                            searchFieldValue: searchFieldValue,
                            market: _selectedMarket,
                            sectors: _selectedSectors,
                          ));
                    }
                  },
                ),
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

                  context.read<StockRankingsBloc>().add(
                      FilterStockRankingsEvent(
                          market: _selectedMarket, sectors: _selectedSectors));
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
            context.read<NavigationCubit>().resetNavigation();
          },
          child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
            builder: (context, state) {
              if (state is StockRankingsInitial) {
                context.read<StockRankingsBloc>().add(GetStockRankingsEvent(
                    market: _selectedMarket, sectors: _selectedSectors));
                return const Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              } else if (state is StockRankingsLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              } else if (state is StockRankingsLoaded) {
                return _buildStockRankingList(context, state);
              } else if (state is StockRankingsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child:
                              Text(state.message, textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<StockRankingsBloc>().add(
                              GetStockRankingsEvent(
                                  market: _selectedMarket,
                                  sectors: _selectedSectors));
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
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
        if (_currentSearchFieldValue.isEmpty) {
          context.read<StockRankingsBloc>().add(PullToRefreshStockRankingsEvent(
              market: _selectedMarket, sectors: _selectedSectors));
        }
        _checkInternetConnection();
      },
      notificationPredicate: (ScrollNotification scrollInfo) {
        return _currentSearchFieldValue.isEmpty;
      },
      color: Colors.blue,
      child: ListView.builder(
        itemCount:
            state.rankedStocks.length + (state.hasReachedMaxData ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.rankedStocks.length &&
              state.rankedStocks.isNotEmpty) {
            final nextPage =
                (state.rankedStocks.length ~/ ApiConstants.defaultLoadLimit) +
                    1; // TODO: Should calculate max next page from count
            context.read<StockRankingsBloc>().add(LoadMoreStockRankingsEvent(
                page: nextPage,
                market: _selectedMarket,
                sectors: _selectedSectors));
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

  void _showMarketFilterDialog(BuildContext context) {
    showDialog<Map<String, String>>(
      context: context,
      builder: (context) => MarketFilter(
          selectedMarket: _selectedMarket,
          onMarketSelected: (market) {
            Navigator.pop(context, {
              'market': market,
            });
          }),
    ).then((result) {
      if (result != null) {
        final market = result['market'] ?? ApiConstants.defaultMarket;
        if (market != _selectedMarket) {
          setState(() {
            _selectedMarket = market;
          });

          context.read<StockRankingsBloc>().add(FilterStockRankingsEvent(
              market: _selectedMarket, sectors: _selectedSectors));
        }
      }
    });
  }

  void _checkInternetConnection() {
    context.read<NetworkInfoBloc>().add(CheckConnectionEvent());
  }
}
