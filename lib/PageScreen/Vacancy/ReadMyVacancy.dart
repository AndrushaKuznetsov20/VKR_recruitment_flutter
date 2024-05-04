import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recruitment/Models/Vacancy.dart';
import 'package:http/http.dart' as http;
import '../../Models/Response.dart';
import '../../Models/User.dart';
import '../Employer/EmployerPage.dart';
import '../LK/LK.dart';
import '../LK/ProfileUser.dart';
import 'UpdateVacancy.dart';

class ReadMyVacancy extends StatefulWidget {
  final String token;

  ReadMyVacancy({required this.token});

  @override
  ReadMyVacancyState createState() => ReadMyVacancyState();
}

class ReadMyVacancyState extends State<ReadMyVacancy> {
  List<Vacancy> dataList = [];
  List<User> dataListUser = [];
  List<Response> dataListResponse = [];
  int currentPage = 0;

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

  Future<void> listResponseVacancy(BuildContext context, int vacancyId) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/response/listUsers/$vacancyId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      List<User> responses = [];
      for (var responseJson in jsonData) {
        responses.add(User.fromJson(responseJson));
      }

      setState(() {
        dataListUser = responses;
      });
    }
  }

  Future<void> listResponse(BuildContext context, int vacancyId) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/response/listResponse/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;

      List<Response> responses = [];
      for (var responseJson in jsonData) {
        responses.add(Response.fromJson(responseJson));
      }

      setState(() {
        dataListResponse = responses;
      });
    }
  }

  Future<void> deleteVacancy(BuildContext context,int vacancyId) async {
    final response = await http.delete(
      Uri.parse(
          'http://172.20.10.3:8092/vacancy/delete/$vacancyId'),
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReadMyVacancy(token: widget.token)));
  }

  void showDeleteConfirmationDialog(BuildContext context, int vacancyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить вакансию?'),
          content: Text('Вы действительно хотите удалить эту вакансию?'),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.not_interested, color: Colors.red),
              label: Text('Нет'),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                deleteVacancy(context, vacancyId);
              },
              icon: Icon(Icons.check, color: Colors.green),
              label: Text('Да'),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
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
          'Мои вакансии',
          style: TextStyle(color: Colors.white),
        ),
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
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.description_vacancy.codeUnits)),
                              Divider(),
                              Text('Условия и требования:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.conditions_and_requirements.codeUnits)),
                              Divider(),
                              Text('Заработная плата:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.wage.toString()),
                              Divider(),
                              Text('График:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: dataListResponse.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Icon(Icons.person),
                                              SizedBox(width: 8.0),
                                              Text(dataListResponse[index].user.username),
                                              SizedBox(width: 8.0),
                                              Text(utf8.decode(dataListResponse[index].statusResponse.codeUnits),style: TextStyle(
                                                color: utf8.decode(dataListResponse[index].statusResponse.codeUnits) == 'Не обработан!' ? Colors.red : Colors.green,
                                              ),),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ProfileUser(token: widget.token, id: dataListResponse[index].user.id, vacancyId: data.id)));
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 200,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      listResponse(context, data.id);
                                    },
                                    icon: Icon(Icons.visibility),
                                    label: Text('Показать отклики'),
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
                                SizedBox(height: 12.0,),
                                SizedBox(
                                  width: 200,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        dataListResponse = [];
                                      });
                                    },
                                    icon: Icon(Icons.visibility_off),
                                    label: Text('Скрыть отклики'),
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
                                SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete_forever,
                                          color: Colors.black),
                                      onPressed: () {
                                        showDeleteConfirmationDialog(
                                            context, data.id);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.black),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => UpdateVacancy(
                                                    token: widget.token,
                                                    id: data.id,
                                                    name_vacancy:
                                                        data.name_vacancy,
                                                    description_vacancy: data
                                                        .description_vacancy,
                                                    conditions_and_requirements:
                                                        data.conditions_and_requirements,
                                                    wage: data.wage,
                                                    schedule: data.schedule)));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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