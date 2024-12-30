import 'package:tarsier_websocket_client/src/pusher_client_socket.dart';

/// A client for interacting with the Tarsier WebSocket service.
///
/// [TarsierWebsocketClient] extends the functionality of [PusherClient] and
/// serves as the primary interface for developers to interact with the
/// Tarsier WebSocket-based API.
///
/// Example:
/// ```dart
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
class TarsierWebsocketClient extends PusherClient {
  /// Creates an instance of [TarsierWebsocketClient].
  ///
  /// The [options] parameter is required and configures the connection,
  /// including server URI and authentication settings.
  TarsierWebsocketClient({required super.options});
}
