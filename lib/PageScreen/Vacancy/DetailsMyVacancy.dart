import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recruitment/Models/Vacancy.dart';
import 'package:http/http.dart' as http;
import 'package:recruitment/PageScreen/Metrics/MetricsPage.dart';
import '../../Models/Response.dart';
import '../../Models/User.dart';
import '../LK/LK.dart';
import 'package:intl/intl.dart';

class DetailsMyVacancy extends StatefulWidget {
  final String token;

  DetailsMyVacancy({required this.token});

  @override
  DetailsMyVacancyState createState() => DetailsMyVacancyState();
}

class DetailsMyVacancyState extends State<DetailsMyVacancy> {
  List<Vacancy> dataList = [];
  List<User> dataListUser = [];
  List<Response> dataListResponse = [];
  int currentPage = 0;

  String resultCountResponses = '';
  String resultCountSelfDanial = '';
  String resultCountRelevantResponse = '';
  String resultCountRefusalEmployer = '';
  String resultCountInvitation = '';

  @override
  void initState() {
    super.initState();
    listMyVacancies(currentPage, context);
  }

  Future<void> listMyVacancies(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/vacancy/listMyVacancies/$pageNo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<Vacancy> vacancies = [];
      for (var entry in jsonData.entries) {
        var key = entry.key;
        var value = entry.value;

        if (key == 'vacancies') {
          for (var vacancyJson in value) {
            vacancies.add(Vacancy.fromJson(vacancyJson));
          }
        }
        if (vacancies.isEmpty) {
          currentPage--;
          listMyVacancies(currentPage, context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Вакансий больше нет!"),
            ),
          );
        }
      }
      setState(() {
        dataList = vacancies;
      });
    }
  }

  Future<void> calculateCountResponses(DateTime startDate, DateTime endDate) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateTimeFormatted = formatter.format(startDate);
    final endDateTimeFormatted = formatter.format(endDate);

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/vacancyResponseCount/$startDateTimeFormatted/$endDateTimeFormatted'),
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

  void nextPage() {
    setState(() {
      currentPage++;
      listMyVacancies(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listMyVacancies(currentPage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Cтатистика',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MetricsPage(token: widget.token)));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LK(token: widget.token)),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final data = dataList[index];
                return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.menu, color: Colors.grey.shade900),
                          SizedBox(width: 8),
                          Text('${utf8.decode(data.name_vacancy.codeUnits)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900)),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Описание вакансии:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8
                                  .decode(data.description_vacancy.codeUnits)),
                              Divider(),
                              Text('Условия и требования:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(
                                  data.conditions_and_requirements.codeUnits)),
                              Divider(),
                              Text('Заработная плата:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.wage.toString()),
                              Divider(),
                              Text('График:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.schedule.codeUnits)),
                              Divider(),
                              Text('Статус вакансии:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                utf8.decode(data.status_vacancy.codeUnits),
                                style: TextStyle(
                                  color: utf8.decode(
                                              data.status_vacancy.codeUnits) ==
                                          'Заблокирована!'
                                      ? Colors.red
                                      : utf8.decode(data
                                                  .status_vacancy.codeUnits) ==
                                              'Опубликована!'
                                          ? Colors.green
                                          : Colors.black,
                                ),
                              ),
                              Divider(),
                              Text('Метрики вакансии:', style: TextStyle(fontWeight: FontWeight.bold)),

                            ],
                          ),
                        ),
                      ],
                    ));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey.shade900),
                  onPressed: previousPage,
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Страница ${currentPage + 1}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.grey.shade900),
                  onPressed: nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}