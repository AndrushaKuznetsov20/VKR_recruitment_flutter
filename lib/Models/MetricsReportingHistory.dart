class MetricsReportingHistory {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int countVacancies;
  final int countResponses;
  final int countSelfDanial;
  final int countRelevantResponse;
  final int countRefusalEmployer;
  final int countInvitation;
  final int countFoundResume;
  final int userId;

  MetricsReportingHistory({required this.id,required this.startDate,
    required this.endDate, required this.countVacancies,required this.countResponses,
    required this.countSelfDanial,required this.countRelevantResponse,required this.countRefusalEmployer,required this.countInvitation,
    required this.countFoundResume, required this.userId});

  factory MetricsReportingHistory.fromJson(Map<String, dynamic> json) {
    return MetricsReportingHistory(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      countVacancies: json['countVacancies'],
      countResponses: json['countResponses'],
      countSelfDanial: json['countSelfDanial'],
      countRelevantResponse: json['countRelevantResponse'],
      countRefusalEmployer: json['countRefusalEmployer'],
      countInvitation: json['countInvitation'],
      countFoundResume: json['countFoundResume'],
      userId: json['userId'],
    );
  }
}