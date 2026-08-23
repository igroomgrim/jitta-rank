import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_info_service.dart';

abstract class NetworkInfoEvent extends Equatable {
  const NetworkInfoEvent();

  @override
  List<Object?> get props => [];
}

/// Explicit one-off check. Still useful on pull-to-refresh.
class CheckConnectionEvent extends NetworkInfoEvent {
  const CheckConnectionEvent();
}

/// Emitted internally when the service's stream reports a change.
class ConnectionChangedEvent extends NetworkInfoEvent {
  const ConnectionChangedEvent({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

class NetworkInfoState extends Equatable {
  const NetworkInfoState({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  NetworkInfoBloc(this.networkInfoService)
      : super(const NetworkInfoState(isConnected: false)) {
    on<CheckConnectionEvent>(_onCheckConnection);
    on<ConnectionChangedEvent>(_onConnectionChanged);

    // Subscribing here means connectivity is tracked continuously rather than
    // only when a screen remembers to ask.
    _subscription = networkInfoService.onStatusChange.listen(
      (isConnected) => add(ConnectionChangedEvent(isConnected: isConnected)),
    );
    add(const CheckConnectionEvent());
  }

  final NetworkInfoService networkInfoService;
  StreamSubscription<bool>? _subscription;

  Future<void> _onCheckConnection(
    CheckConnectionEvent event,
    Emitter<NetworkInfoState> emit,
  ) async {
    emit(NetworkInfoState(isConnected: await networkInfoService.isConnected));
  }

  void _onConnectionChanged(
    ConnectionChangedEvent event,
    Emitter<NetworkInfoState> emit,
  ) {
    emit(NetworkInfoState(isConnected: event.isConnected));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
