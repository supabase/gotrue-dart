class UserAttributes {
  String? email;
  String? phone;
  String? password;
  String? emailChangeToken;
  dynamic data;

  UserAttributes({this.email, this.phone, this.password, this.emailChangeToken, this.data});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> values = {};
    if (email != null) values['email'] = email;
    if (phone != null) values['phone'] = phone;
    if (password != null) values['password'] = password;
    if (emailChangeToken != null) {
      values['email_change_token'] = emailChangeToken;
    }
    if (data != null) values['data'] = data;
    return values;
  }
}
