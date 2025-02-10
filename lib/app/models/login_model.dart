class LoginResponse {
  final String? refresh;
  final String? access;
  final UserModel user;

  LoginResponse({
    required this.refresh,
    required this.access,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      refresh: json['refresh'],
      access: json['access'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final int id;
  final String username;
  final String phone;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.username,
    required this.phone,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      phone: json['phone'],
      isAdmin: json['isAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'isAdmin': isAdmin,
    };
  }
}
