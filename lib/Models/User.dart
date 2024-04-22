import 'Role.dart';

class User {
  final int id;
  final String username;
  final String email;
  final bool active;
  final Role role;

  User({required this.id,required this.username, required this.email, required this.active, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      active: json['active'],
      role: _convertStringToRole(json['role']),
    );
  }
  static Role _convertStringToRole(String roleString) {
    switch (roleString) {
      case 'ROLE_USER':
        return Role.ROLE_USER;
      case 'ROLE_ADMIN':
        return Role.ROLE_ADMIN;
      case 'ROLE_MODER':
        return Role.ROLE_MODER;
      case 'ROLE_EMPLOYER':
        return Role.ROLE_EMPLOYER;
      default:
        throw Exception('Неизвестная роль: $roleString');
    }
  }
}