class FetchOptions {
  final Map<String, String> headers;
  final bool noResolveJson;

  FetchOptions(this.headers, {this.noResolveJson = false});
}
