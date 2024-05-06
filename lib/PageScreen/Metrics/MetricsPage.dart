import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:recruitment/PageScreen/Metrics/MetricsReportingHistoryPage.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Models/Vacancy.dart';
import '../Employer/EmployerPage.dart';
import '../Home.dart';
import '../LK/LK.dart';
import '../Vacancy/DetailsMyVacancy.dart';
class MetricsPage extends StatefulWidget {
  final String token;
  MetricsPage({required this.token});

  @override
  _MetricsPageState createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late DateTime startDate;
  late DateTime endDate;
  String resultCountVacancies = '';
  String resultCountResponses = '';
  String resultCountSelfDanial = '';
  String resultCountRelevantResponse = '';
  String resultCountRefusalEmployer = '';
  String resultCountInvitation = '';

  int countVacancies = 0;
  int countResponses = 0;
  int countSelfDanial = 0;
  int countRelevantResponse = 0;
  int countRefusalEmployer = 0;
  int countInvitation = 0;

  List<Map<String, dynamic>> chartData = [];
  List<String> columnNames = [
    'Кол-во вакансий',
    'Кол-во откликов',
    'Кол-во релевантных откликов',
    'Кол-во самоотказов',
    'Кол-во отказов работодателя',
    'Кол-во приглашений'
  ];

  List<int> columnValues = [0, 0, 0, 0, 0, 0];

  List<Vacancy> dataList = [];

  Future<void> calculateCountVacancies(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countVacancy/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countVacancies = int.parse(response.body);
        resultCountVacancies = response.body;
        columnValues[0] = newValue;
        chartData[0] = {
          'columnName': columnNames[0],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void> calculateCountResponses(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countAllResponses/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countResponses = int.parse(response.body);
        resultCountResponses = response.body;
        columnValues[1] = newValue;
        chartData[1] = {
          'columnName': columnNames[1],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void>  calculateCountSelfDanial(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countAllSelfDanial/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countSelfDanial = int.parse(response.body);
        resultCountSelfDanial = response.body;
        columnValues[2] = newValue;
        chartData[2] = {
          'columnName': columnNames[2],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void>  calculateCountRelevantResponse(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countAllRelevantResponses/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countRelevantResponse = int.parse(response.body);
        resultCountRelevantResponse = response.body;
        columnValues[3] = newValue;
        chartData[3] = {
          'columnName': columnNames[3],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void>  calculateCountRefusalEmployer(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countAllRefusalEmployer/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countRefusalEmployer = int.parse(response.body);
        resultCountRefusalEmployer = response.body;
        columnValues[4] = newValue;
        chartData[4] = {
          'columnName': columnNames[4],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void>  calculateCountInvitation(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countAllInvitation/$startDateTimeFormatted/$endDateTimeFormatted'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      int newValue = int.parse(response.body);
      setState(() {
        countInvitation = int.parse(response.body);
        resultCountInvitation = response.body;
        columnValues[5] = newValue;
        chartData[5] = {
          'columnName': columnNames[5],
          'columnValue': newValue,
        };
      });
    }
  }

  Future<void> calculateAllMetrics(BuildContext context, DateTime startDate, DateTime endDate) async {
    calculateCountVacancies(startDate, endDate);
    calculateCountResponses(startDate, endDate);
    calculateCountRelevantResponse(startDate, endDate);
    calculateCountSelfDanial(startDate, endDate);
    calculateCountRefusalEmployer(startDate, endDate);
    calculateCountInvitation(startDate, endDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Метрики успешно рассчитаны!"),
      ),
    );
  }

  Future<void> createMetricsReporting(BuildContext context, DateTime startDate, DateTime endDate) async {

    int userId = extractIdFromToken(widget.token);
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final url = Uri.parse('http://172.20.10.3:8092/metricsReportingHistory/create');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'startDate':startDateTimeFormatted,
      'endDate':endDateTimeFormatted,
      'countVacancies':countVacancies,
      'countResponses':countResponses,
      'countSelfDanial':countSelfDanial,
      'countRelevantResponse':countRelevantResponse,
      'countRefusalEmployer':countRefusalEmployer,
      'countInvitation':countInvitation,
      'userId':userId
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }

  }

  int extractIdFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int id = decodedToken['id'];
    return id;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Выберите дату',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
    for (int i = 0; i < columnNames.length; i++) {
      chartData.add({
        'columnName': columnNames[i],
        'columnValue': columnValues[i],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Рассчёт метрик', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmployerPage(token: widget.token)));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => LK(token: widget.token)));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _selectDate(context, true);
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text('Выбор даты начала'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              Divider(),
              Text(startDate != null
                  ? 'Дата начала: ${dateFormat.format(startDate)}'
                  : 'Выберите дату начала',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              Divider(),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _selectDate(context, false);
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text('Выбор даты окончания'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 8),
              Text(endDate != null
                  ? 'Дата окончания: ${dateFormat.format(endDate)}'
                  : 'Выберите дату окончания',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество вакансий: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountInvitation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество откликов: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountResponses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество релевантных откликов: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountRelevantResponse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество самоотказов: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountSelfDanial',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество отказов работодателя: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountRefusalEmployer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text('Количество приглашений: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$resultCountInvitation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    calculateAllMetrics(context, startDate, endDate);
                  },
                  icon: Icon(Icons.calculate_outlined),
                  label: Text('Рассчитать метрики'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    createMetricsReporting(context, startDate, endDate);
                  },
                  icon: Icon(Icons.save),
                  label: Text('Сохранить отчёт'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MetricsReportingHistoryPage(token: widget.token)));
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Перейти к истории отчётов'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsMyVacancy(token: widget.token)));
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Перейти к своим вакансиям'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ),
              Divider(),
              Container(
                height: 400,
                width: double.infinity,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Рассчитанные метрики'),
                  primaryXAxis: CategoryAxis(
                    labelRotation: 90,
                  ),
                  series: <ChartSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: chartData,
                      xValueMapper: (Map<String, dynamic> data, _) => data['columnName'],
                      yValueMapper: (Map<String, dynamic> data, _) => data['columnValue'],
                      width: 0.8,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      pointColorMapper: (Map<String, dynamic> data, _) {
                        if (data['columnName'] == 'Кол-во вакансий') {
                          return Colors.green.shade500;
                        } else if (data['columnName'] == 'Кол-во откликов') {
                          return Colors.red.shade500;
                        } else if (data['columnName'] == 'Кол-во релевантных откликов') {
                          return Colors.blue.shade500;
                        } else if (data['columnName'] == 'Кол-во самоотказов') {
                          return Colors.purple.shade500;
                        } else if (data['columnName'] == 'Кол-во отказов работодателя') {
                          return Colors.yellow.shade700;
                        }
                        return Colors.grey.shade500;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

