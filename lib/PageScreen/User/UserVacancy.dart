import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recruitment/Models/Vacancy.dart';
import 'package:http/http.dart' as http;
import 'package:recruitment/PageScreen/User/UserPage.dart';

import '../LK/LK.dart';
import '../Moder/ModerPage.dart';

class UserVacancy extends StatefulWidget {
  final String token;

  UserVacancy({required this.token});

  @override
  UserVacancyState createState() => UserVacancyState();
}

class UserVacancyState extends State<UserVacancy> {
  List<Vacancy> dataList = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    listVacancySetStatusOk(currentPage, context);
  }

  Future<void> listVacancySetStatusOk(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/vacancy/listVacanciesStatusOk/$pageNo'),
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
          listVacancySetStatusOk(currentPage, context);

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

  Future<void> createResponse(int vacancyId, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.3:8092/response/create/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  void nextPage() {
    setState(() {
      currentPage++;
      listVacancySetStatusOk(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listVacancySetStatusOk(currentPage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Актуальные вакансии',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserPage(token: widget.token)));
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  createResponse(data.id, context);
                                },
                                icon: Icon(Icons.star_outlined, color: Colors.yellow),
                                label: Text('Оставть отклик'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // setStatusVacancyBlock(data.id, context);
                                },
                                icon: Icon(Icons.message, color: Colors.blue),
                                label: Text('Написать работодателю'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.white),
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
