import 'User.dart';

class Resume {
  final int id;
  final String fullName;
  final DateTime birthDate;
  final int age;
  final String city;
  final String skills;
  final String education;
  final String otherInfo;
  final String statusResume;
  final User user;

  Resume({required this.id,required this.fullName,
    required this.birthDate, required this.age,required this.city,
    required this.skills,required this.education,required this.otherInfo,required this.statusResume,
    required this.user});

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'],
      fullName: json['fullName'],
      birthDate: DateTime.parse(json['birthDate']),
      age: json['age'],
      city: json['city'],
      skills: json['skills'],
      education: json['education'],
      otherInfo: json['otherInfo'],
      statusResume: json['statusResume'],
      user: User.fromJson(json['user']),
    );
  }
}