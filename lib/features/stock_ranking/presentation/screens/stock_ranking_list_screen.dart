import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/debounced_search_field.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/sector_filter.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/market_filter.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Stock Rankings',
              textAlign: TextAlign.center,
            ),
            Text(
              MarketFilter.getMarketName(_selectedMarket),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
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
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
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
                      context.read<StockRankingsBloc>().add(SearchStockRankingsEvent(searchFieldValue));
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

                  context.read<StockRankingsBloc>().add(FilterStockRankingsEvent(market: _selectedMarket, sectors: _selectedSectors));
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
                  context.read<StockRankingsBloc>().add(GetStockRankingsEvent(market: _selectedMarket, sectors: _selectedSectors));
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
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      );
  }

  Widget _buildStockRankingList(BuildContext context, StockRankingsLoaded state) {
    if (state.rankedStocks.isEmpty) {
      return const Center(child: Text("No stocks found!"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_currentSearchFieldValue.isEmpty) {
          context.read<StockRankingsBloc>().add(RefreshStockRankingsEvent(sectors: _selectedSectors));
        }
      },
      notificationPredicate: (ScrollNotification scrollInfo) {
        return _currentSearchFieldValue.isEmpty;
      },
      child: ListView.builder(
        itemCount: state.rankedStocks.length + (state.hasReachedMaxData ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.rankedStocks.length && state.rankedStocks.isNotEmpty) {
            final nextPage = (state.rankedStocks.length ~/ ApiConstants.defaultLoadLimit) + 1; // TODO: Should calculate max next page from count
            context.read<StockRankingsBloc>().add(
              GetStockRankingsEvent(page: nextPage, market: _selectedMarket, sectors: _selectedSectors)
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

  void _showMarketFilterDialog(BuildContext context) {
    showDialog<Map<String, String>>(
      context: context,
      builder: (context) => MarketFilter(selectedMarket: _selectedMarket, onMarketSelected: (market) {
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

          context.read<StockRankingsBloc>().add(FilterStockRankingsEvent(market: _selectedMarket, sectors: _selectedSectors));
        }
      }
    });
  }
}
