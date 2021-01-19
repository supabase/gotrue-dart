import 'dart:svg';

class CookieOptions {
  final String name;
  final int lifetime;
  final String domain;
  final String path;
  final String sameSite;

  const CookieOptions(this.name, this.lifetime, this.domain, this.path, this.sameSite);
}