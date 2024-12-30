import '../channels/channel.dart';
import '../pusher_client_socket.dart';
import '../utils/collection.dart';

/// Represents a collection of channels in Pusher.
///
/// This class manages the lifecycle of channels, including creation,
/// retrieval, and clearing. It extends the [Collection] class to provide
/// additional functionality specific to Pusher channels.
class ChannelsCollection extends Collection<Channel> {
  /// The Pusher client associated with the channels.
  final PusherClient client;

  /// Creates an instance of [ChannelsCollection].
  ///
  /// The [client] parameter specifies the Pusher client that owns this collection.
  ChannelsCollection(this.client);

  /// Retrieves a channel by its name, creating it if it does not already exist.
  ///
  /// The [channelName] parameter specifies the name of the channel.
  /// The [subscribe] parameter, if `true`, subscribes to the channel upon creation.
  ///
  /// Supported channel types:
  /// - **Private Encrypted Channels**: Names starting with `private-encrypted-`.
  /// - **Private Channels**: Names starting with `private-`.
  /// - **Presence Channels**: Names starting with `presence-`.
  /// - **Public Channels**: All other channel names.
  ///
  /// Returns a channel of type [T], which must extend [Channel].
  T channel<T extends Channel>(String channelName, {bool subscribe = false}) {
    if (!contains(channelName)) {
      if (channelName.startsWith("private-encrypted-")) {
        add(
          channelName,
          PrivateEncryptedChannel(
            client: client,
            name: channelName,
          ),
        );
      } else if (channelName.startsWith("private-")) {
        add(
          channelName,
          PrivateChannel(
            client: client,
            name: channelName,
          ),
        );
      } else if (channelName.startsWith("presence-")) {
        add(
          channelName,
          PresenceChannel(
            client: client,
            name: channelName,
          ),
        );
      } else {
        add(
          channelName,
          Channel(client: client, name: channelName),
        );
      }
    }

    T channel = super.get(channelName)! as T;
    if (subscribe) {
      channel.subscribe();
    }

    return channel;
  }

  /// Unsubscribes from all channels and clears the collection.
  ///
  /// This method first iterates through all channels in the collection,
  /// calling [unsubscribe] on each. Then, it clears the collection.
  @override
  void clear() {
    forEach((channel) => channel.unsubscribe());
    super.clear();
  }
}
