import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


import '../../Models/Vacancy.dart';
import '../Employer/EmployerPage.dart';
import '../Home.dart';
import '../LK/LK.dart';
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
      setState(() {
        resultCountVacancies = response.body;
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
      setState(() {
        resultCountResponses = response.body;
      });
    }
  }

  Future<void>  calculateCountAllSelfDanial(DateTime startDate, DateTime endDate) async {
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
      setState(() {
        resultCountSelfDanial = response.body;
      });
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
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
              SizedBox(height: 12),
              Text(startDate != null
                  ? 'Дата начала: ${dateFormat.format(startDate)}'
                  : 'Выберите дату начала',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ElevatedButton.icon(
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
              SizedBox(height: 12),
              Text(endDate != null
                  ? 'Дата окончания: ${dateFormat.format(endDate)}'
                  : 'Выберите дату окончания',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  calculateCountVacancies(startDate, endDate);
                },
                icon: Icon(Icons.work),
                label: Text('Рассчитать количество вакансий'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 12),
              Text('Количество вакансий: $resultCountVacancies',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  calculateCountResponses(startDate, endDate);
                },
                icon: Icon(Icons.bar_chart),
                label: Text('Рассчитать количество откликов'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 12),
              Text('Количество откликов: $resultCountResponses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  (startDate, endDate);
                },
                icon: Icon(Icons.cancel_outlined),
                label: Text('Рассчитать количество релевантных откликов'),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 12),
              Text('Количество самоотказов: $resultCountSelfDanial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  calculateCountAllSelfDanial(startDate, endDate);
                },
                icon: Icon(Icons.cancel_outlined),
                label: Text('Рассчитать количество самоотказов'),
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 12),
              Text('Количество самоотказов: $resultCountSelfDanial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
