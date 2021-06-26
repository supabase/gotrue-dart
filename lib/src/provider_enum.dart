enum ProviderEnum { azure, bitbucket, facebook, github, gitlab, google }

extension ProviderName on ProviderEnum {
  String name() {
    return toString().split('.').last;
  }
}
