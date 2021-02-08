enum Provider { bitbucket, github, gitlab, google }

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}
