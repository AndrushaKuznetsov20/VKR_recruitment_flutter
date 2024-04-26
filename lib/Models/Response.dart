import 'User.dart';
import 'Vacancy.dart';

class Response {
  final int id;
  // final Vacancy vacancy;
  final User user;
  // final DateTime currentDateTime;
  final String statusResponse;

  Response({required this.id,
    required this.user, required this.statusResponse});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'],
      // vacancy: Vacancy.fromJson(json['vacancy']),
      user: User.fromJson(json['user']),
      // currentDateTime: DateTime.parse(json['currentDateTime']),
      statusResponse: json['statusResponse'],
    );
  }
}