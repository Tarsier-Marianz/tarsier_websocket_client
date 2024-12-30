/// Tarsier WebSocket Client Library
///
/// A Dart library for interacting with WebSocket-based services using the
/// Tarsier WebSocket client. This library provides tools for managing
/// WebSocket connections, subscribing to channels, and handling real-time
/// events.
///
/// To get started, import the library and initialize a `TarsierWebsocketClient`:
///
/// Example:
/// ```dart
/// import 'package:tarsier_websocket_client/tarsier_websocket_client.dart';
///
/// final client = TarsierWebsocketClient(
///   options: PusherOptions(
///     uri: 'wss://example.com/socket',
///     authOptions: PusherAuthOptions(
///       endpoint: 'https://example.com/auth',
///       headers: {'Authorization': 'Bearer token'},
///     ),
///   ),
/// );
/// client.connect();
/// ```
library tarsier_websocket_client;

export 'src/tarsier_websocket_client_base.dart';
export 'src/pusher_client_socket.dart';
export 'src/misc/options.dart';
