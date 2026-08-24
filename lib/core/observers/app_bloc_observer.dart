import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs bloc lifecycle in debug builds so state transitions and unhandled bloc
/// errors are visible without attaching a debugger.
///
/// Registered only when [kDebugMode] is true, so it costs nothing in release.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
      '${bloc.runtimeType}: ${transition.event.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stackTrace);
  }
}
