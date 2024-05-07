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
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDeleteConfirmationDialog(context, data.id);
                                },
                                icon: Icon(Icons.delete_forever),
                                label: Text('Удалить отклик'),
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