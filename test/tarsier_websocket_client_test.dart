import 'package:tarsier_websocket_client/tarsier_websocket_client.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    var options = PusherOptions(
      key: 'YOUR_KEY',
      host: '127.0.0.1',
      wsPort: 6001,
      encrypted: false, // (Note: enable it if you are using wss connection)
      authOptions: PusherAuthOptions(
        'http://localhost/broadcasting/auth',
      ),
      autoConnect: false,
      enableLogging: false,
    );
    final client = TarsierWebsocketClient(options: options);

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(client.connected, isTrue);
    });
  });
}
