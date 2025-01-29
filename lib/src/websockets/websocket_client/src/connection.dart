import 'dart:async';

import 'package:tarsier_websocket_client/src/websockets/websocket_client/src/socket_connection_state.dart';

/// An object which contains information regarding the
/// current WebSocket connection.
abstract class Connection extends Stream<SocketConnectionState> {
  /// The current state of the WebSocket connection.
  SocketConnectionState get state;
}

/// {@template connection_controller}
/// A WebSocket connection controller.
/// {@endtemplate}
class ConnectionController extends Connection {
  /// {@macro connection_controller}
  ConnectionController()
      : _state = const Connecting(),
        _controller = StreamController<SocketConnectionState>.broadcast();

  SocketConnectionState _state;
  final StreamController<SocketConnectionState> _controller;

  @override
  SocketConnectionState get state => _state;

  @override
  StreamSubscription<SocketConnectionState> listen(
    void Function(SocketConnectionState event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _stream.distinct().listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  Stream<SocketConnectionState> get _stream async* {
    yield _state;
    yield* _controller.stream;
  }

  /// Notifies listeners of a new connection [state].
  void add(SocketConnectionState state) {
    _state = state;
    _controller.add(state);
  }

  /// Closes the controller's stream.
  void close() => _controller.close();
}
