class FetchOptions {
  final Map<String, String> headers;
  final bool noResolveJson;

  const FetchOptions(
    Map<String, String>? headers, {
    this.noResolveJson = false,
  }) : headers = headers ?? const {};
}
