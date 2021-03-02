class FetchOptions {
  Map<String, String> headers;
  bool? noResolveJson;

  FetchOptions(Map<String, String>? headers, {this.noResolveJson})
      : headers = headers ?? {};
}
