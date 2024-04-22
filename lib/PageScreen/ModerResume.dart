import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Resume.dart';
import 'LK.dart';
import 'ModerPage.dart';
import 'package:intl/intl.dart';

class ModerResume extends StatefulWidget {
  final String token;
  ModerResume({required this.token});

  @override
  ModerResumeState createState() => ModerResumeState();
}
class ModerResumeState extends State<ModerResume>
{
  List<Resume> dataList = [];
  int currentPage = 0;
  int countVacancy = 0;

  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    listResume(currentPage, context);
  }

  Future<void> listResume(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.186:8092/resume/list/$pageNo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<Resume> resumes = [];
      for (var entry in jsonData.entries) {
        var key = entry.key;
        var value = entry.value;

        if (key == 'resumes') {
          for (var resumeJson in value) {
            resumes.add(Resume.fromJson(resumeJson));
          }
        }
        if(resumes.isEmpty){
          currentPage--;
          listResume(currentPage,context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Резюме больше нет!"),
            ),
          );
        }
      }
      setState(() {
        dataList = resumes;
      });
    }
  }

  Future<void> setStatusResumeOk(int id,BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.186:8092/resume/setStatusOk/$id'),
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
    listResume(currentPage,context);
  }

  Future<void> setStatusResumeBlock(int id, BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.186:8092/resume/setStatusBlock/$id'),
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
    listResume(currentPage,context);
  }

  void nextPage() {
    setState(() {
      currentPage++;
      listResume(currentPage,context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listResume(currentPage,context);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Модерация резюме',style: TextStyle(color: Colors.white),),
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
                          Text('${utf8.decode(data.fullName.codeUnits)}',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Дата рождения:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(dateFormat.format(data.birthDate)),
                              Divider(),
                              Text('Возраст:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.age.toString()),
                              Divider(),
                              Text('Город:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.city.codeUnits)),
                              Divider(),
                              Text('Навыки:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.skills.codeUnits)),
                              Divider(),
                              Text('Образование:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.education.codeUnits)),
                              Divider(),
                              Text('Другая информация:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.otherInfo.codeUnits)),
                              Divider(),
                              Text('Статус резюме:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                utf8.decode(data.statusResume.codeUnits),
                                style: TextStyle(
                                  color: utf8.decode(data.statusResume.codeUnits) == 'Заблокировано!' ? Colors.red : utf8.decode(data.statusResume.codeUnits) == 'Опубликовано!' ? Colors.green : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setStatusResumeOk(data.id, context);
                                },
                                child: Text('Опубликовать'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setStatusResumeBlock(data.id, context);
                                },
                                child: Text('Заблокировать'),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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