class UserAttributes {
  /// The user's email.
  String? email;

  /// The user's phone.
  String? phone;

  /// The user's password.
  String? password;

  /// A custom data object to store the user's metadata. This maps to the `auth.users.user_metadata` column.
  ///
  /// The `data` should be a JSON object that includes user-specific info, such as their first and last name.
  dynamic data;

  UserAttributes({
    this.email,
    this.phone,
    this.password,
    this.data,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> values = {};
    if (email != null) values['email'] = email;
    if (phone != null) values['phone'] = phone;
    if (password != null) values['password'] = password;
    if (data != null) values['data'] = data;
    return values;
  }
}
