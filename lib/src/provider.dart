enum Provider {
  apple,
  azure,
  bitbucket,
  discord,
  facebook,
  github,
  gitlab,
  google,
  slack,
  spotify,
  twitch,
  twitter,
}

extension ProviderName on Provider {
  String name() {
    return toString().split('.').last;
  }
}
