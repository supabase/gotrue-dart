enum Provider { azure, bitbucket, facebook, github, gitlab, google }

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}
