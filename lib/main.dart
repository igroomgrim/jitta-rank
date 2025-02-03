import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/core.dart';
import 'package:jitta_rank/features/stock_ranking/stock_ranking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<NavigationCubit>()),
        BlocProvider(create: (context) => getIt<StockRankingsBloc>()),
        BlocProvider(create: (context) => getIt<NetworkInfoBloc>()),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.stockRankingListScreen,
      ),
    );
  }
}
