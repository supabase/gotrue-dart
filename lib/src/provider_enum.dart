enum ProviderEnum { azure, bitbucket, facebook, github, gitlab, google }

extension ProviderName on ProviderEnum {
  String get name => toString().split('.').last;
}
