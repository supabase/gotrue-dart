class UserAttributes {
  String email;
  String password;
  String emailChangeToken;
  dynamic data;

  UserAttributes({this.email, this.password, this.emailChangeToken, this.data});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'email_change_token': emailChangeToken,
        'data': data,
      };
}
