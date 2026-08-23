import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jitta_rank/core/networking/network_info_bloc.dart';
import 'package:jitta_rank/core/networking/network_info_service.dart';

/// Hand-written rather than generated: the test needs to push values into the
/// stream mid-test, which a stubbed getter cannot do.
class _FakeNetworkInfoService implements NetworkInfoService {
  final _controller = StreamController<bool>.broadcast();
  bool connected = false;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void emit(bool value) {
    connected = value;
    _controller.add(value);
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  late _FakeNetworkInfoService service;

  setUp(() => service = _FakeNetworkInfoService());
  tearDown(() => service.dispose());

  blocTest<NetworkInfoBloc, NetworkInfoState>(
    'checks connectivity on construction without being asked',
    // The bloc used to only ever learn about connectivity from an explicit
    // CheckConnectionEvent dispatched by a screen.
    build: () {
      service.connected = true;
      return NetworkInfoBloc(service);
    },
    expect: () => [const NetworkInfoState(isConnected: true)],
  );

  blocTest<NetworkInfoBloc, NetworkInfoState>(
    'tracks the service stream, so going online is noticed on its own',
    build: () => NetworkInfoBloc(service),
    act: (_) async {
      await Future<void>.delayed(Duration.zero);
      service.emit(true);
      await Future<void>.delayed(Duration.zero);
      service.emit(false);
    },
    skip: 1, // the construction-time check
    expect: () => [
      const NetworkInfoState(isConnected: true),
      const NetworkInfoState(isConnected: false),
    ],
  );

  blocTest<NetworkInfoBloc, NetworkInfoState>(
    'an unchanged status emits nothing, because the state is Equatable',
    build: () => NetworkInfoBloc(service),
    act: (_) async {
      await Future<void>.delayed(Duration.zero);
      service
        ..emit(true)
        ..emit(true);
    },
    skip: 1,
    expect: () => [const NetworkInfoState(isConnected: true)],
  );

  test('cancels its subscription on close', () async {
    final bloc = NetworkInfoBloc(service);
    await Future<void>.delayed(Duration.zero);
    await bloc.close();

    // Emitting after close must not throw "add after close".
    expect(() => service.emit(true), returnsNormally);
  });
}
