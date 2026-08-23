import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/core.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/features/stock_ranking/mock_stock_ranking_data.dart';

class _MockStockRankingsBloc
    extends MockBloc<StockRankingsEvent, StockRankingsState>
    implements StockRankingsBloc {}

class _MockNavigationCubit extends MockCubit<NavigationState?>
    implements NavigationCubit {}

class _MockNetworkInfoBloc extends MockBloc<NetworkInfoEvent, NetworkInfoState>
    implements NetworkInfoBloc {}

void main() {
  late _MockStockRankingsBloc rankingsBloc;
  late _MockNavigationCubit navigationCubit;
  late _MockNetworkInfoBloc networkBloc;

  setUp(() {
    rankingsBloc = _MockStockRankingsBloc();
    navigationCubit = _MockNavigationCubit();
    networkBloc = _MockNetworkInfoBloc();

    when(() => navigationCubit.state).thenReturn(null);
    when(() => networkBloc.state).thenReturn(
      const NetworkInfoState(isConnected: true),
    );
  });

  Future<void> pump(WidgetTester tester, StockRankingsState state) async {
    when(() => rankingsBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<NavigationCubit>.value(value: navigationCubit),
          BlocProvider<NetworkInfoBloc>.value(value: networkBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: BlocProvider<StockRankingsBloc>.value(
            value: rankingsBloc,
            // The view, not the route wrapper: the wrapper resolves its bloc from
            // getIt, which is not set up in a widget test.
            child: const StockRankingListView(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders one card per stock', (tester) async {
    await pump(
      tester,
      StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 3),
      ),
    );

    expect(find.byType(StockRankingItem), findsNWidgets(3));
    // The symbol is a TextSpan inside a RichText, not a Text widget.
    expect(find.textContaining('SYM1', findRichText: true), findsOneWidget);
  });

  testWidgets('shows a spinner while the first load is in flight', (
    tester,
  ) async {
    await pump(tester, const StockRankingsState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty message when a successful load has no rows', (
    tester,
  ) async {
    await pump(
      tester,
      const StockRankingsState(
        status: StockRankingsStatus.success,
        hasReachedMaxData: true,
      ),
    );

    expect(find.text('No stocks found!'), findsOneWidget);
  });

  testWidgets('a first-load failure takes over the screen', (tester) async {
    await pump(
      tester,
      const StockRankingsState(
        status: StockRankingsStatus.failure,
        errorMessage: 'You are offline',
      ),
    );

    expect(find.text('You are offline'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.byType(StockRankingItem), findsNothing);
  });

  testWidgets('a load-more failure keeps the list and shows an inline retry', (
    tester,
  ) async {
    // The regression this phase's state consolidation exists for: a failure
    // used to replace the whole list with a full-page error.
    await pump(
      tester,
      StockRankingsState(
        status: StockRankingsStatus.failure,
        // Kept small so the list and its footer both fit the test viewport;
        // ListView builds lazily and would not render off-screen rows.
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 2),
        errorMessage: 'Network hiccup',
      ),
    );

    expect(find.byType(StockRankingItem), findsNWidgets(2));
    expect(find.text('Network hiccup'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('no trailing spinner once the end of the data is reached', (
    tester,
  ) async {
    await pump(
      tester,
      StockRankingsState(
        status: StockRankingsStatus.success,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 3),
        hasReachedMaxData: true,
      ),
    );

    expect(find.byType(StockRankingItem), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a trailing spinner shows while more data is expected', (
    tester,
  ) async {
    await pump(
      tester,
      StockRankingsState(
        status: StockRankingsStatus.loadingMore,
        rankedStocks: MockStockRankingData.getMockStockRankings(count: 3),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('dispatches the initial load once, from initState', (
    tester,
  ) async {
    await pump(tester, const StockRankingsState());
    await tester.pump();
    await tester.pump();

    // Firing from BlocBuilder's builder meant a fetch on every rebuild.
    verify(() => rankingsBloc.add(const GetStockRankingsEvent())).called(1);
  });
}
