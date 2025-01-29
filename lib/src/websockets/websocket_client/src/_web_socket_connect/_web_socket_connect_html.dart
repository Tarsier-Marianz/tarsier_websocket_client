import 'dart:async';
import 'dart:html' as html;

/// Create a WebSocket connection.
Future<html.WebSocket> connect(
  String url, {
  Iterable<String>? protocols,
  Map<String, dynamic>? headers, // Headers are not supported in browsers.
  Duration? pingInterval,
  String? binaryType,
}) async {
  final socket =
      protocols != null ? html.WebSocket(url, protocols) : html.WebSocket(url);

  // Either "blob" (default) or "arraybuffer".
  // https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/binaryType
  socket.binaryType = binaryType ?? 'blob';

  if (socket.readyState == html.WebSocket.OPEN) return socket;

  final completer = Completer<html.WebSocket>();

  socket.onOpen.first.then((_) {
    completer.complete(socket);
  });

  socket.onError.first.then((event) {
    completer.completeError('WebSocket connection failed');
  });

  return completer.future;
}
