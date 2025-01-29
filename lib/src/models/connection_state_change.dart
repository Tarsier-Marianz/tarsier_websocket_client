class ConnectionStateChange {
  /// The current connection state. The state the connection has transitioned
  /// to.
  final String? currentState;

  /// The previous connections state. The state the connection has transitioned
  /// from.
  final String? previousState;

  ConnectionStateChange({
    this.currentState,
    this.previousState,
  });
}
