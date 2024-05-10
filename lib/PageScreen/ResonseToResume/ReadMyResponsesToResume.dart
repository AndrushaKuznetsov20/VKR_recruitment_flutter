import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/Resume.dart';
import 'package:intl/intl.dart';
import '../LK/LK.dart';

class ReadMyResponsesToResume extends StatefulWidget {
  final String token;
  ReadMyResponsesToResume({required this.token});

  @override
  ReadMyResponsesToResumeState createState() => ReadMyResponsesToResumeState();
}

class ReadMyResponsesToResumeState extends State<ReadMyResponsesToResume>
{
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  List<Resume> dataListResume= [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    listMyResponsesToResume(currentPage, context);
  }

  Future<void> listMyResponsesToResume(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/responseToResume/listMyResponsesToResume/$pageNo'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      List<Resume> resumes = [];
      for (var responseJson in jsonData) {
        resumes.add(Resume.fromJson(responseJson));
      }

      if (resumes.isEmpty) {
        currentPage--;
        listMyResponsesToResume(currentPage, context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Откликов больше нет!"),
          ),
        );
      }

      setState(() {
        dataListResume = resumes;
      });
    }
  }

  Future<void> deleteResponseToResume(BuildContext context, int responseToResumeId) async {
    final response = await http.delete(
      Uri.parse(
          'http://172.20.10.3:8092/responseToResume/delete/$responseToResumeId'),
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
    listMyResponsesToResume(currentPage,context);
    Navigator.of(context).pop();
  }

  void showDeleteConfirmationDialog(BuildContext context, int responseToResumeId) {
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
                deleteResponseToResume(context, responseToResumeId);
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
      listMyResponsesToResume(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listMyResponsesToResume(currentPage, context);
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
              itemCount: dataListResume.length,
              itemBuilder: (context, index) {
                final data = dataListResume[index];
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
                              '${utf8.decode(data.fullName.codeUnits)}',
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
                                    Icons.calendar_month,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Дата рождения:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(dateFormat.format(data.birthDate),
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
                                    Icons.cake,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Возраст:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(data.age.toString(),
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
                                    Icons.location_city,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Город:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(utf8.decode(data.city.codeUnits),
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
                                    Icons.work,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Навыки:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(utf8.decode(data.skills.codeUnits),
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
                                    Icons.school,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Образование:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(utf8.decode(data.education.codeUnits),
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
                                    Icons.info,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Другая информация:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(utf8.decode(data.otherInfo.codeUnits),
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
                                    color: Colors.black, ),
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