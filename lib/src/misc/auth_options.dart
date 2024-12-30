/// Represents the options for authentication with the Pusher service.
///
/// [PusherAuthOptions] defines the endpoint and headers used during the
/// authentication process. These options are used to authenticate channels
/// and ensure secure communication.
class PusherAuthOptions {
  /// The endpoint URL for the authentication requests.
  ///
  /// This is the server endpoint that handles the authentication for private
  /// or presence channels. It must be a valid URL.
  final String endpoint;

  /// The headers sent with the authentication requests.
  ///
  /// Defaults to `{'Accept': 'application/json'}`. You can include additional
  /// headers such as authorization tokens, content type, etc.
  final Map<String, String> headers;

  /// Creates an instance of [PusherAuthOptions].
  ///
  /// The [endpoint] is required and specifies the authentication endpoint.
  /// The optional [headers] parameter allows customization of the headers
  /// sent with authentication requests.
  const PusherAuthOptions(
      this.endpoint, {
        this.headers = const {
          'Accept': 'application/json',
        },
      });

  /// Returns a string representation of the [PusherAuthOptions] instance.
  ///
  /// Includes the endpoint and headers in the output.
  @override
  String toString() {
    return 'AuthOptions(endpoint: $endpoint, headers: $headers)';
  }
}
