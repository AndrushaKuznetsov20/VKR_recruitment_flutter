import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recruitment/Models/Vacancy.dart';
import 'package:http/http.dart' as http;

import '../LK/LK.dart';
import 'ModerPage.dart';

class ModerVacancy extends StatefulWidget {
  final String token;
  ModerVacancy({required this.token});

  @override
  ModerVacancyState createState() => ModerVacancyState();
}
class ModerVacancyState extends State<ModerVacancy>
{
  List<Vacancy> dataList = [];
  int currentPage = 0;
  int countVacancy = 0;

  @override
  void initState() {
    super.initState();
    listVacancy(currentPage, context);
  }

  Future<void> listVacancy(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/vacancy/list/$pageNo'),
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
        if(vacancies.isEmpty){
          currentPage--;
          listVacancy(currentPage,context);

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

  Future<void> setStatusVacancyOk(int id,BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://172.20.10.3:8092/vacancy/setStatusOk/$id'),
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
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    listVacancy(currentPage,context);
  }

  Future<void> setStatusVacancyBlock(int id, BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://172.20.10.3:8092/vacancy/setStatusBlock/$id'),
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
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    listVacancy(currentPage,context);
  }

    void nextPage() {
      setState(() {
        currentPage++;
        listVacancy(currentPage,context);
      });
    }

    void previousPage() {
      if (currentPage > 0) {
        setState(() {
          currentPage--;
          listVacancy(currentPage,context);
        });
      }
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Модерация вакансий',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.grey.shade900,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ModerPage(token: widget.token)));
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LK(token: widget.token)),
                );
              },
            ),
          ],
        ),
        body: Column(
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
                          Text('${utf8.decode(data.name_vacancy.codeUnits)}',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Описание вакансии:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.description_vacancy.codeUnits)),
                              Divider(),
                              Text('Условия и требования:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.conditions_and_requirements.codeUnits)),
                              Divider(),
                              Text('Заработная плата:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.wage.toString()),
                              Divider(),
                              Text('График:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.schedule.codeUnits)),
                              Divider(),
                              Text('Статус вакансии:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                utf8.decode(data.status_vacancy.codeUnits),
                                style: TextStyle(
                                  color: utf8.decode(data.status_vacancy.codeUnits) == 'Заблокирована!' ? Colors.red : utf8.decode(data.status_vacancy.codeUnits) == 'Опубликована!' ? Colors.green : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setStatusVacancyOk(data.id, context);
                                },
                                icon: Icon(Icons.done, color: Colors.green),
                                label: Text('Опубликовать'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 5),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setStatusVacancyBlock(data.id, context);
                                },
                                icon: Icon(Icons.block_outlined, color: Colors.red),
                                label: Text('Заблокировать'),
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
                    )
                  );
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