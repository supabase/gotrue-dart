class CookieOptions {
  final String name;
  final int lifetime;
  final String domain;
  final String path;
  final String sameSite;

  const CookieOptions({
    this.name = 'sb:token',
    this.lifetime = 60 * 80 * 8,
    this.domain = '',
    this.path = '/',
    this.sameSite = 'lax',
  });
}
