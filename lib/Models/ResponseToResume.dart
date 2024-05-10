import 'Resume.dart';
import 'User.dart';

class ResponseToResume {
  final int id;
  final User user;
  final Resume resume;
  final DateTime responseDate;

  ResponseToResume({required this.id,
    required this.user, required this.resume, required this.responseDate});

  factory ResponseToResume.fromJson(Map<String, dynamic> json) {
    return ResponseToResume(
      id: json['id'],
      user: User.fromJson(json['user']),
      resume: Resume.fromJson(json['resume']),
      responseDate: DateTime.parse(json['responseDate']),
    );
  }
}