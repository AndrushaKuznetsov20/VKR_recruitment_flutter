import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:recruitment/Models/Vacancy.dart';
import 'package:http/http.dart' as http;
import 'package:recruitment/PageScreen/User/UserPage.dart';

import '../Chat/ChatPage.dart';
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

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController scheduleController = TextEditingController();
  TextEditingController conditionsController = TextEditingController();
  RangeValues currentRangeValues = const RangeValues(0, 1000000);

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

  int extractIdFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int id = decodedToken['id'];
    return id;
  }

  void searchVacancies() {
    String? nameVacancy = nameController.text.isNotEmpty ? nameController.text : null;
    String? description = descriptionController.text.isNotEmpty ? descriptionController.text : null;
    String? schedule = scheduleController.text.isNotEmpty ? scheduleController.text : null;
    String? conditions = conditionsController.text.isNotEmpty ? conditionsController.text : null;
    int? minWage = currentRangeValues.start.round();
    int? maxWage = currentRangeValues.end.round();

    foundVacancies(nameVacancy, description, schedule, conditions, minWage, maxWage);
  }

  Future<void> foundVacancies(String? nameVacancy, String? description, String? schedule, String? conditions, int? minWage, int? maxWage) async {
    final queryParameters = {
      'nameVacancy': nameVacancy,
      'description': description,
      'schedule': schedule,
      'conditions_and_requirements': conditions,
      'minWage': minWage?.toString(),
      'maxWage': maxWage?.toString(),
    };

    final queryString = queryParameters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/vacancy/searchVacancies?$queryString'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;

      List<Vacancy> vacancies = [];
      for (var responseJson in jsonData) {
        vacancies.add(Vacancy.fromJson(responseJson));
      }

      setState(() {
        dataList = vacancies;
      });
    }

    // if (response.statusCode == 200) {
    //   final jsonData = json.decode(response.body);
    //
    //   List<Vacancy> vacancies = [];
    //   if (jsonData is List) {
    //     for (var vacancyJson in jsonData) {
    //       if (vacancyJson is Map && vacancyJson.containsKey('vacancies')) {
    //         for (var vacancy in vacancyJson['vacancies']) {
    //           vacancies.add(Vacancy.fromJson(vacancy));
    //         }
    //       }
    //     }
    //   }
    //
    //   setState(() {
    //     dataList = vacancies;
    //   });
    // }

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaleFactor: 1.0),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    top: 16.0,
                                    left: 16.0,
                                    right: 16.0,
                                  ),
                                child: SingleChildScrollView(
                                child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Поиск по названию вакансии',
                                            prefixIcon: Icon(Icons.title,
                                              color: Colors.black,),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          cursorColor: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: descriptionController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Поиск по описанию вакансии',
                                            prefixIcon: Icon(Icons.description,
                                              color: Colors.black,),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          cursorColor: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: scheduleController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Поиск по графику вакансии',
                                            prefixIcon: Icon(Icons.schedule,
                                              color: Colors.black,),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          cursorColor: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: conditionsController,
                                          decoration: InputDecoration(
                                            hintText: 'Поиск по требованиям',
                                            prefixIcon: Icon(
                                              Icons.assignment_turned_in,
                                              color: Colors.black,
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.black),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          cursorColor: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Выберите размер ЗП',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            RangeSlider(
                                              values: currentRangeValues,
                                              min: 0,
                                              max: 1000000,
                                              divisions: 30,
                                              labels: RangeLabels(
                                                currentRangeValues.start.round().toString(),
                                                currentRangeValues.end.round().toString(),
                                              ),
                                              activeColor: Colors.black,
                                              inactiveColor: Colors.grey,
                                              onChanged: (RangeValues values) {
                                                setState(() {
                                                  currentRangeValues = values;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          foundVacancies(
                                              nameController.text,
                                              descriptionController.text,
                                              scheduleController.text,
                                              conditionsController.text,
                                              currentRangeValues.start.round(),
                                              currentRangeValues.end.round());
                                          Navigator.pop(context);
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                          foregroundColor:
                                          MaterialStateProperty.all<Color>(Colors.white),
                                        ),
                                        child: Text('Применить фильтры'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                  ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.filter_alt),
                  label: Text('Фильтры'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 10,),
                ElevatedButton.icon(
                  onPressed: () {
                    listVacancySetStatusOk(currentPage, context);
                    nameController.clear();
                    descriptionController.clear();
                    conditionsController.clear();
                    scheduleController.clear();
                    currentRangeValues = const RangeValues(0, 1000000);
                  },
                  icon: Icon(Icons.filter_alt_off),
                  label: Text('Сброс'),
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
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    createResponse(data.id, context);
                                  },
                                  icon: Icon(Icons.star_outlined, color: Colors.yellow),
                                  label: Text('Оставить отклик'),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                    foregroundColor:
                                    MaterialStateProperty.all<Color>(Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatPage(token: widget.token, senderId: extractIdFromToken(widget.token), receiverId: data.user.id)));
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
                              ),
                            ],
                          ),
                        )
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
