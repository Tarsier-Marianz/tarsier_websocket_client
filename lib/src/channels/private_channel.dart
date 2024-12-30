import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_data.dart';
import '../utils/member.dart';
import 'channel.dart';

/// Represents a private channel in Pusher, which allows for authenticated user interactions.
///
/// The `PrivateChannel` class extends the base `Channel` class 
/// and adds functionalities specific to private channels, including
/// user authentication and subscription management.
class PrivateChannel extends Channel {
  /// Creates a [PrivateChannel] instance with the specified [client] and [name].
  ///
  /// The [client] parameter is the instance of the Pusher client,
  /// and the [name] parameter is the name of the channel to connect to.
  PrivateChannel({
    required super.client,
    required super.name,
  }) {
    onSubscriptionSuccess(_onSubscriptionSuccess);
    onSubscriptionCount(_onSubscriptionCount);
  }

  String? userId;

  /// The user member of the channel.
  ///
  /// Returns a [Member] instance if [userId] is not null;
  /// Otherwise, returns null. The [Member] class represents
  /// the authenticated user subscribed to this channel.
  Member? get member => userId != null ? Member(id: userId!) : null;

  AuthData? authData;

  /// Subscribes to the private channel.
  ///
  /// This method sends a subscription request to the server and retrieves
  /// the authentication data needed to authenticate the channel
  /// for the current user. If the client is not connected or already
  /// subscribed (unless forced), this operation will not be performed.
  /// 
  /// Throws an [Exception] if the authentication response is invalid
  /// or if the subscription fails.
  @override
  void subscribe([bool force = false]) async {
    if (!client.connected || (subscribed && !force) || client.socketId == null) {
      return;
    }

    subscribed = false;

    options.log("SUBSCRIBE", name);

    final payload = {
      "channel_name": name,
      "socket_id": client.socketId,
    };

    final response = await http.post(
      Uri.parse(authOptions.endpoint),
      body: payload,
      headers: authOptions.headers,
    );

    options.log(
      "AUTH_RESPONSE",
      name,
      "options: $authOptions\n  payload: $payload\n  response: ${response.body}",
    );

    if (response.statusCode == 200) {
      // try {
      final data = jsonDecode(response.body);

      if (data is! Map) {
        throw Exception(
          "Invalid auth response data [$data], expected Map got ${data.runtimeType}",
        );
      } else if (!data.containsKey("auth")) {
        throw Exception(
          "Invalid auth response data [$data], auth key is missing",
        );
      }
      authData = AuthData.fromJson(data);
      userId = authData!.channelData?.userId;
      client.sendEvent("pusher:subscribe", {
        "channel": name,
        "auth": authData!.auth,
        "channel_data": authData!.channelData?.toJsonString(),
      });
      // } catch (e) {
      //   handleEvent("pusher:error", e);
      // }
    } else {
      handleEvent(
        "pusher:error",
        "Unable to authenticate channel $name, status code: ${response.statusCode}",
      );
    }
  }

  void _onSubscriptionSuccess(data) {
    options.log("SUBSCRIPTION_SUCCESS", name, "data: $data");

    subscribed = true;
  }

  int _subscriptionCount = 0;

  /// The number of subscriptions to the channel.
  ///
  /// This property returns the count of current subscriptions
  /// to the private channel, which can be useful for managing
  /// and displaying the channel's state.
  int get subscriptionCount => _subscriptionCount;

  void _onSubscriptionCount(data) {
    options.log("SUBSCRIPTION_COUNT", name, "data: $data");

    _subscriptionCount = data["subscription_count"];
  }

  /// Binds a listener function to the subscription count event.
  ///
  /// The [listener] function will be called whenever the subscription
  /// count changes, allowing for real-time updates on the number of
  /// subscribers to the channel.
  void onSubscriptionCount(Function listener) => bind("pusher:subscription_count", listener);

  /// Sends an event to the channel.
  ///
  /// The [event] parameter specifies the name of the event to trigger.
  /// If the event name does not start with "client-", it will be prefixed
  /// with "client-" to indicate that it is a client event. The optional
  /// [data] parameter contains the data to be sent with the event.
  void trigger(String event, [data]) {
    options.log("TRIGGER", name, "event: $event\n  data: $data");

    if (!event.startsWith("client-")) {
      event = "client-$event";
    }

    client.sendEvent(event, data, name);
  }
}

