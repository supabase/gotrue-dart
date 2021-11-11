enum Provider {
  apple,
  azure,
  bitbucket,
  discord,
  facebook,
  github,
  gitlab,
  google,
  twitch,
  twitter,
  slack,
  spotify
}

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}
