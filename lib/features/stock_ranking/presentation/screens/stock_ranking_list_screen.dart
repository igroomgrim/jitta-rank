import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/constants/api_constants.dart';
import 'package:jitta_rank/core/di/injection_container.dart';
import 'package:jitta_rank/core/navigation/app_router.dart';
import 'package:jitta_rank/core/navigation/navigation_cubit.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';
import 'package:jitta_rank/features/stock_ranking/presentation/widgets/stock_ranking_app_bar.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

class StockRankingListScreen extends StatelessWidget {
  const StockRankingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StockRankingsBloc>(),
      child: const _StockRankingListView(),
    );
  }
}

class _StockRankingListView extends StatefulWidget {
  const _StockRankingListView();

  @override
  State<_StockRankingListView> createState() => _StockRankingListViewState();
}

class _StockRankingListViewState extends State<_StockRankingListView> {
  /// How close to the bottom (in pixels) triggers the next page.
  static const _loadMoreThreshold = 300.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Dispatched here, not from BlocBuilder's builder. Firing events during
    // build ran on every rebuild and made the fetch a side effect of painting.
    context.read<StockRankingsBloc>().add(const GetStockRankingsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _checkInternetConnection() {
    context.read<NetworkInfoBloc>().add(const CheckConnectionEvent());
  }

  /// Load-more is driven by scroll position rather than by ListView building
  /// its trailing item, so a rebuild cannot trigger a fetch.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels > _loadMoreThreshold) return;

    final bloc = context.read<StockRankingsBloc>();
    final state = bloc.state;
    if (state.hasReachedMaxData || state.isLoadingMore) return;
    if (state.filter.searchFieldValue.isNotEmpty) return;

    bloc.add(
      LoadMoreStockRankingsEvent(
        page: (state.rankedStocks.length ~/ ApiConstants.defaultLimit) + 1,
        market: state.filter.market,
        sectors: state.filter.sectors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StockRankingAppBar(
        onFilterPressed: () => _showMarketFilterDialog(context),
      ),
      body: MultiBlocListener(
        listeners: [
          // Refetch when connectivity is restored. Deliberately a listener in
          // the screen rather than a subscription inside StockRankingsBloc:
          // NetworkInfoBloc is core and StockRankingsBloc is a feature, so
          // wiring them bloc-to-bloc would invert the layering.
          BlocListener<NetworkInfoBloc, NetworkInfoState>(
            listenWhen: (previous, current) =>
                !previous.isConnected && current.isConnected,
            listener: (context, _) {
              final bloc = context.read<StockRankingsBloc>();
              bloc.add(
                PullToRefreshStockRankingsEvent(
                  market: bloc.state.filter.market,
                  sectors: bloc.state.filter.sectors,
                ),
              );
            },
          ),
          BlocListener<NavigationCubit, NavigationState?>(
            listener: (context, state) {
              if (state is NavigateToStockDetailScreen) {
                Navigator.pushNamed(
                  context,
                  AppRouter.stockDetailScreen,
                  arguments: state.stockId,
                );
                context.read<NavigationCubit>().resetNavigation();
              }
            },
          ),
        ],
        child: BlocBuilder<StockRankingsBloc, StockRankingsState>(
          builder: (context, state) {
            if (state.hasFailedWithNoData) {
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong',
                onRetry: () => context.read<StockRankingsBloc>().add(
                      GetStockRankingsEvent(
                        market: state.filter.market,
                        sectors: state.filter.sectors,
                      ),
                    ),
              );
            }

            if (state.rankedStocks.isEmpty) {
              return switch (state.status) {
                StockRankingsStatus.initial ||
                StockRankingsStatus.loading =>
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                _ => const Center(child: Text('No stocks found!')),
              };
            }

            return _buildStockRankingList(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildStockRankingList(
    BuildContext context,
    StockRankingsState state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        if (state.filter.searchFieldValue.isEmpty) {
          context.read<StockRankingsBloc>().add(
                PullToRefreshStockRankingsEvent(
                  market: state.filter.market,
                  sectors: state.filter.sectors,
                ),
              );
        }
        _checkInternetConnection();
      },
      notificationPredicate: (_) => state.filter.searchFieldValue.isEmpty,
      child: ListView.builder(
        controller: _scrollController,
        // One extra slot for the footer, which is a spinner while a page is in
        // flight and an inline error when one failed. A failure no longer
        // replaces the list that is already on screen.
        itemCount: state.rankedStocks.length + (_hasFooter(state) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.rankedStocks.length) {
            return _ListFooter(state: state);
          }
          return StockRankingItem(
            rankedStock: state.rankedStocks[index],
            onTap: (rankedStock) => context
                .read<NavigationCubit>()
                .navigateToStockDetailScreen(rankedStock.stockId),
          );
        },
      ),
    );
  }

  bool _hasFooter(StockRankingsState state) =>
      state.isLoadingMore || state.hasFailed || !state.hasReachedMaxData;

  void _showMarketFilterDialog(BuildContext context) {
    // Must come from the widget tree, not getIt: the bloc is registered as a
    // factory, so getIt would hand back a different instance than the one this
    // screen is showing.
    final bloc = context.read<StockRankingsBloc>();

    showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: MarketFilter(
          selectedMarket: bloc.state.filter.market,
          onMarketSelected: (market) =>
              Navigator.pop(dialogContext, {'market': market}),
        ),
      ),
    ).then((result) {
      if (result == null || !mounted) return;
      bloc.add(
        FilterStockRankingsEvent(
          searchFieldValue: bloc.state.filter.searchFieldValue,
          market: result['market'] ?? ApiConstants.defaultMarket,
          sectors: bloc.state.filter.sectors,
        ),
      );
    });
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final StockRankingsState state;

  @override
  Widget build(BuildContext context) {
    if (state.hasFailed) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              state.errorMessage ?? 'Could not load more',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<StockRankingsBloc>().add(
                    LoadMoreStockRankingsEvent(
                      page: (state.rankedStocks.length ~/
                              ApiConstants.defaultLimit) +
                          1,
                      market: state.filter.market,
                      sectors: state.filter.sectors,
                    ),
                  ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
