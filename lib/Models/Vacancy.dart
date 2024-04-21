import 'User.dart';

class Vacancy {
  final int id;
  final String name_vacancy;
  final String description_vacancy;
  final String conditions_and_requirements;
  final int wage;
  final String schedule;
  final String status_vacancy;
  final User user;

  Vacancy({required this.id,required this.name_vacancy,
    required this.description_vacancy, required this.conditions_and_requirements,required this.wage,
    required this.schedule,required this.status_vacancy,required this.user});

  factory Vacancy.fromJson(Map<String, dynamic> json) {
    return Vacancy(
      id: json['id'],
      name_vacancy: json['name_vacancy'],
      description_vacancy: json['description_vacancy'],
      conditions_and_requirements: json['conditions_and_requirements'],
      wage: json['wage'],
      schedule: json['schedule'],
      status_vacancy: json['status_vacancy'],
      user: User.fromJson(json['user']),
    );
  }
}