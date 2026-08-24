import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitta_rank/core/core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Bloc.observer = const AppBlocObserver();
  }
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
        BlocProvider(create: (context) => getIt<NetworkInfoBloc>()),
      ],
      child: MaterialApp(
        title: 'Jitta Rank',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Follows the system setting; both themes are fully defined.
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.stockRankingListScreen,
      ),
    );
  }
}
