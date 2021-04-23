enum Provider { azure, bitbucket, facebook, github, gitlab, google }

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}

class ProviderOptions {
  final String? redirectTo;
  final String? scopes;

  ProviderOptions({this.redirectTo, this.scopes});
}
