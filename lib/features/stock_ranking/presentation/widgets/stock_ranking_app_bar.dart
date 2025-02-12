import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';

class StockRankingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onFilterPressed;
  final double _appBarHeight = 168.0;

  const StockRankingAppBar({super.key, required this.onFilterPressed});

  @override
  Size get preferredSize => Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: AppBar(
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
              onPressed: onFilterPressed,
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
        ));
  }
}
