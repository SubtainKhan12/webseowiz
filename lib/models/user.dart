class LoginUser {
  final String email;
  final String accessToken;

  LoginUser({required this.email, required this.accessToken});

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      email: json['email'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}
