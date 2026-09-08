/// Thin wrapper around the real HTTP layer.
///
/// TODO: once the Node.js backend is ready, add `http` or `dio` to
/// pubspec.yaml and implement this, e.g.:
///
/// class ApiClient {
///   final http.Client _client = http.Client();
///
///   Future<Map<String, dynamic>> post(
///     String path, {
///     Map<String, dynamic>? body,
///   }) async {
///     final response = await _client.post(
///       Uri.parse('${ApiEndpoints.baseUrl}$path'),
///       headers: {'Content-Type': 'application/json'},
///       body: jsonEncode(body),
///     );
///     return jsonDecode(response.body) as Map<String, dynamic>;
///   }
/// }
///
/// AuthService below already calls this shape of API — swapping the
/// mock implementations for real calls will need no UI changes.
class ApiClient {
  const ApiClient();
}