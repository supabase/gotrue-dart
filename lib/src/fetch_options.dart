class FetchOptions {
  final Map<String, String> headers;
  final bool noResolveJson;

  const FetchOptions(this.headers, {this.noResolveJson = false});
}
