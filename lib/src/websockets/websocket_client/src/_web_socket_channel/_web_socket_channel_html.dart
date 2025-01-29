import 'dart:html' as html;
import 'package:tarsier_websocket_client/src/websockets/websocket_channel/html.dart';
import 'package:tarsier_websocket_client/src/websockets/websocket_channel/web_socket_channel.dart';

/// Get an [HtmlWebSocketChannel] for the provided [socket].
WebSocketChannel getWebSocketChannel(html.WebSocket socket) {
  return HtmlWebSocketChannel(socket);
}
