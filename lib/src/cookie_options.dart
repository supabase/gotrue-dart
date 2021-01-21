class CookieOptions {
  final String name;
  final int lifetime;
  final String domain;
  final String path;
  final String sameSite;

  const CookieOptions(
      {String name, int lifetime, String domain, String path, String sameSite})
      : name = name ?? 'sb:token',
        lifetime = lifetime ?? 60 * 60 * 8,
        domain = domain ?? '',
        path = path ?? '/',
        sameSite = sameSite ?? 'lax';
}
