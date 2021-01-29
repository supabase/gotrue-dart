class User {
  String id;
  Map<String, dynamic> appMetadata;
  Map<String, dynamic> userMetadata;
  String aud;
  String email;
  String createdAt;
  String confirmedAt;
  String lastSignInAt;
  String role;
  String updatedAt;

  User(
      {this.id,
      this.appMetadata,
      this.userMetadata,
      this.aud,
      this.email,
      this.createdAt,
      this.confirmedAt,
      this.lastSignInAt,
      this.role,
      this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        appMetadata: json['app_metadata'] as Map<String, dynamic>,
        userMetadata: json['user_metadata'] as Map<String, dynamic>,
        aud: json['aud'] as String,
        email: json['email'] as String,
        createdAt: json['created_at'] as String,
        confirmedAt: json['confirmed_at'] as String,
        lastSignInAt: json['last_sign_in_at'] as String,
        role: json['role'] as String,
        updatedAt: json['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'app_metadata': appMetadata,
        'user_metadata': userMetadata,
        'aud': aud,
        'email': email,
        'created_at': createdAt,
        'confirmed_at': confirmedAt,
        'last_sign_in_at': lastSignInAt,
        'role': role,
        'updated_at': updatedAt,
      };
}
