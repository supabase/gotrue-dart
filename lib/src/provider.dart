enum Provider { apple, azure, bitbucket, discord, facebook, github, gitlab, google, twitter }

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}
