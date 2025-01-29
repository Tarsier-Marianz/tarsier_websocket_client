import 'dart:io' as io;

import 'package:tarsier_websocket_client/src/websockets/websocket_channel/io.dart';
import 'package:tarsier_websocket_client/src/websockets/websocket_channel/web_socket_channel.dart';

/// Get an [IOWebSocketChannel] for the provided [socket].
WebSocketChannel getWebSocketChannel(io.WebSocket socket) {
  return IOWebSocketChannel(socket);
}
