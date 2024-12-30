import '../utils/collection.dart';

/// Manages a collection of event listeners for Pusher channels.
///
/// This class allows binding, unbinding, and handling event listeners.
/// It also supports wildcard listeners for handling all events.
class EventsListenersCollection extends Collection<List<Function>> {
  /// Binds a listener to a specific event.
  ///
  /// The [event] parameter specifies the event name.
  /// The [listener] is a callback function that will be invoked when the event occurs.
  ///
  /// If the listener is already bound to the event, it will not be added again.
  void bind(String event, Function listener) {
    add(event, []);
    final listeners = get(event)!;
    if (!listeners.contains(listener)) listeners.add(listener);
  }

  /// Unbinds a specific listener from an event.
  ///
  /// The [event] parameter specifies the event name.
  /// The [listener] is the callback function to be removed from the event.
  void unbind(String event, Function listener) {
    final listeners = get(event);
    if (listeners != null && listeners.contains(listener)) {
      listeners.remove(listener);
    }
  }

  /// Unbinds all listeners from a specific event.
  ///
  /// The [event] parameter specifies the event name.
  /// All listeners associated with the event will be removed.
  void unbindAll(String event) => remove(event);

  /// Handles an incoming event and invokes the associated listeners.
  ///
  /// The [event] parameter specifies the event name.
  /// The [data] parameter contains the event payload.
  /// The optional [channel] parameter specifies the channel where the event occurred.
  ///
  /// If a wildcard listener (`*`) is bound, it will receive a map containing
  /// the event name, data, and channel (if applicable).
  void handleEvent(String event, dynamic data, [String? channel]) {
    // Handle specific event listeners.
    if (contains(event)) {
      for (final listener in get(event)!) {
        if (channel == null) {
          listener(data);
        } else {
          listener(data, channel);
        }
      }
    }

    // Handle wildcard listeners.
    if (contains("*")) {
      for (final listener in get("*")!) {
        listener({
          "event": event,
          "data": data,
          if (channel != null) "channel": channel,
        });
      }
    }
  }
}
