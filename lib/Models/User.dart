import 'Role.dart';

class User {
  final int id;
  final String username;
  final String email;
  final bool active;
  // final Role role;

  User({required this.id,required this.username, required this.email, required this.active});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      active: json['active'],
      // role: Role.values.firstWhere((role) => role.toString() == json['role']),
    );
  }
}