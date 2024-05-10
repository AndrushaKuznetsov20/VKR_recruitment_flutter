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

  Map<int, Map<String, String>> metricsMap = {};

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

  Future<void> calculateCountResponses(int vacancyId) async {

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/vacancyResponseCount/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        metricsMap[vacancyId]?['countResponses'] = response.body;
      });
    }
  }

  Future<void>  calculateCountSelfDanial(int vacancyId) async {

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/vacancySelfDanialCount/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        metricsMap[vacancyId]?['countSelfDanial'] = response.body;
      });
    }
  }

  Future<void>  calculateCountRelevantResponse(int vacancyId) async {

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/vacancyRelevantResponsesCount/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        metricsMap[vacancyId]?['countRelevantResponse'] = response.body;
      });
    }
  }

  Future<void>  calculateCountRefusalEmployer(int vacancyId) async {

    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/vacancyRefusalEmployerCount/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        metricsMap[vacancyId]?['countRefusalEmployer'] = response.body;
      });
    }
  }

  Future<void> calculateCountInvitation(int vacancyId) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/metrics/countInvitation/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        metricsMap[vacancyId]?['countInvitation'] = response.body;
      });
    }
  }

  Future<void> calculateAllMetrics(BuildContext context, int vacancyId) async {
    metricsMap[vacancyId] = {};

    await calculateCountResponses(vacancyId);
    await calculateCountRelevantResponse(vacancyId);
    await calculateCountSelfDanial(vacancyId);
    await calculateCountRefusalEmployer(vacancyId);
    await calculateCountInvitation(vacancyId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Метрики успешно рассчитаны!"),
      ),
    );
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
          'Статистика',
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
                          Expanded(
                            child: Text(
                              '${utf8.decode(data.name_vacancy.codeUnits)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 21,
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Описание вакансии:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      utf8.decode(
                                          data.description_vacancy.codeUnits),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 21,
                                  child: Icon(
                                    Icons.assignment_turned_in,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Условия и требования:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      utf8.decode(data
                                          .conditions_and_requirements
                                          .codeUnits),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 21,
                                  child: Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Заработная плата:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(data.wage.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 21,
                                  child: Icon(
                                    Icons.schedule,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'График:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(utf8.decode(data.schedule.codeUnits),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 21,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Статус вакансии:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      utf8.decode(data.status_vacancy.codeUnits),
                                      style: TextStyle(
                                          color: utf8.decode(data.status_vacancy.codeUnits) == 'Заблокирована!' ? Colors.red : utf8.decode(data.status_vacancy.codeUnits) == 'Опубликована!' ? Colors.green : Colors.black,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              SizedBox(
                                width: 200,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    calculateAllMetrics(context,data.id);
                                  },
                                  icon: Icon(Icons.calculate_outlined),
                                  label: Text('Рассчитать метрики'),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade900),
                                    foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ),
                              Divider(),
                              Text('Метрики вакансии:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Row(
                                  children: [
                                    Text('Количество откликов: ',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500)),
                                    Text(
                                      '${metricsMap[data.id]?['countResponses']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500)),
                                    Text(
                                      '${metricsMap[data.id]?['countRelevantResponse']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500)),
                                    Text(
                                      '${metricsMap[data.id]?['countSelfDanial']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500)),
                                    Text(
                                      '${metricsMap[data.id]?['countRefusalEmployer']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500)),
                                    Text(
                                      '${metricsMap[data.id]?['countInvitation']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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