import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/core.dart';
import 'package:jitta_rank/features/stock_detail/stock_detail.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/features/stock_detail/mock_stock_detail_data.dart';

class _MockStockDetailBloc extends MockBloc<StockDetailEvent, StockDetailState>
    implements StockDetailBloc {}

void main() {
  late _MockStockDetailBloc bloc;

  setUpAll(() {
    registerFallbackValue(GetStockDetailEvent(0));
  });

  setUp(() => bloc = _MockStockDetailBloc());

  Future<void> pump(WidgetTester tester, StockDetailState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<StockDetailBloc>.value(
          value: bloc,
          // The view, not the route wrapper: the wrapper resolves its bloc
          // from getIt, which is not set up in a widget test.
          child: const StockDetailView(stockId: 185),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows a spinner before anything has loaded', (tester) async {
    await pump(tester, const StockDetailState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders the loaded stock', (tester) async {
    await pump(
      tester,
      StockDetailState(
        status: StockDetailStatus.success,
        stock: MockStockDetailData.getMockStock(),
      ),
    );

    expect(find.text('Stock Detail'), findsOneWidget);
    expect(find.textContaining('Test Stock', findRichText: true), findsWidgets);
  });

  testWidgets('a first-load failure takes over the screen', (tester) async {
    await pump(
      tester,
      const StockDetailState(
        status: StockDetailStatus.failure,
        errorMessage: 'You are offline',
      ),
    );

    expect(find.text('You are offline'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('a failed refresh keeps the stock that is already shown', (
    tester,
  ) async {
    await pump(
      tester,
      StockDetailState(
        status: StockDetailStatus.failure,
        stock: MockStockDetailData.getMockStock(),
        errorMessage: 'Could not refresh',
      ),
    );

    expect(find.text('Could not refresh'), findsOneWidget);
    // The full-page error must NOT have taken over.
    expect(find.text('Try Again'), findsNothing);
    expect(find.textContaining('Test Stock', findRichText: true), findsWidgets);
  });

  testWidgets('dispatches the initial load once, from initState', (
    tester,
  ) async {
    await pump(tester, const StockDetailState());
    await tester.pump();
    await tester.pump();

    // Firing from BlocBuilder's builder meant a fetch on every rebuild.
    verify(() => bloc.add(any(that: isA<GetStockDetailEvent>()))).called(1);
  });
}
