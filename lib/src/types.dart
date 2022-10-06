enum OtpType {
  sms,
  phoneChange,
  signup,
  invite,
  magiclink,
  recovery,
  emailChange
}

extension ToSnakeCase on Enum {
  String get snakeCase {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return name
        .replaceAllMapped(exp, (Match m) => ('_${m.group(0)}'))
        .toLowerCase();
  }
}
