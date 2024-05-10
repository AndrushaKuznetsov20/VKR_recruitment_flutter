import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/Vacancy.dart';
import '../LK/LK.dart';

class ReadMyResponses extends StatefulWidget {
  final String token;
  ReadMyResponses({required this.token});

  @override
  ReadMyResponsesState createState() => ReadMyResponsesState();
}

class ReadMyResponsesState extends State<ReadMyResponses>
{
  List<Vacancy> dataListVacancy = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    listMyResponses(currentPage, context);
  }

  Future<void> listMyResponses(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/response/listVacancy/$pageNo'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      List<Vacancy> responses = [];
      for (var responseJson in jsonData) {
        responses.add(Vacancy.fromJson(responseJson));
      }

      if (responses.isEmpty) {
        currentPage--;
        listMyResponses(currentPage, context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Откликов больше нет!"),
          ),
        );
      }

      setState(() {
        dataListVacancy = responses;
      });
    }
  }

  Future<void> deleteResponse(BuildContext context, int vacancyId) async {
    final response = await http.delete(
      Uri.parse(
          'http://172.20.10.3:8092/response/delete/$vacancyId'),
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
    listMyResponses(currentPage,context);
    Navigator.of(context).pop();
  }

  void showDeleteConfirmationDialog(BuildContext context, int vacancyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить отклик?'),
          content: Text('Вы действительно хотите удалить этот отклик ?'),
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
                deleteResponse(context, vacancyId);
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
      listMyResponses(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listMyResponses(currentPage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Избранное',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LK(token: widget.token)));
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataListVacancy.length,
              itemBuilder: (context, index) {
                final data = dataListVacancy[index];
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
                              IconButton(
                                iconSize: 30.0,
                                icon: Icon(Icons.delete_forever,
                                    color: Colors.black),
                                onPressed: () {
                                  showDeleteConfirmationDialog(context, data.id);
                                },
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