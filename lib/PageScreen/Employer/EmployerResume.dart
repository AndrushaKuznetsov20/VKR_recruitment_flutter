import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Models/Resume.dart';
import '../LK/LK.dart';
import '../LK/ProfileUser.dart';
import 'EmployerPage.dart';

class EmployerResume extends StatefulWidget {
  final String token;

  EmployerResume({required this.token});

  @override
  EmployerResumeState createState() => EmployerResumeState();
}

class EmployerResumeState extends State<EmployerResume> {
  List<Resume> dataList = [];
  int currentPage = 0;

  TextEditingController cityController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  RangeValues currentRangeValues = const RangeValues(0, 60);

  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    listResumeSetStatusOk(currentPage, context);
  }

  Future<void> listResumeSetStatusOk(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/resume/listResumeStatusOk/$pageNo'),
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
          for (var resumesJson in value) {
            resumes.add(Resume.fromJson(resumesJson));
          }
        }
        if (resumes.isEmpty) {
          currentPage--;
          listResumeSetStatusOk(currentPage, context);

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

  Future<void> createResponseToResume(int resumeId, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.3:8092/responseToResume/create/$resumeId'),
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
      listResumeSetStatusOk(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listResumeSetStatusOk(currentPage, context);
      });
    }
  }

  void searchResumes() {
    String? city = cityController.text.isNotEmpty ? cityController.text : null;
    String? skills = skillsController.text.isNotEmpty ? skillsController.text : null;
    String? education = educationController.text.isNotEmpty ? educationController.text : null;
    int? minAge = currentRangeValues.start.round();
    int? maxAge = currentRangeValues.end.round();

    foundResumes(city, skills, education, minAge, maxAge);
  }

  Future<void> foundResumes(String? city, String? skills, String? education, int? minAge, int? maxAge) async {
    final queryParameters = {
      'city': city,
      'skills': skills,
      'education': education,
      'minAge': minAge?.toString(),
      'maxAge': maxAge?.toString(),
    };

    final queryString = queryParameters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/resume/searchResumes?$queryString'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;

      List<Resume> resumes = [];
      for (var responseJson in jsonData) {
        resumes.add(Resume.fromJson(responseJson));
      }

      setState(() {
        dataList = resumes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Резюме',
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
                                        controller: cityController,
                                        decoration: InputDecoration(
                                          hintText:
                                          'Поиск по городу',
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
                                        controller: skillsController,
                                        decoration: InputDecoration(
                                          hintText:
                                          'Поиск по навыкам',
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
                                        controller: educationController,
                                        decoration: InputDecoration(
                                          hintText: 'Поиск по образованию',
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
                                            'Выберите возраст',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          RangeSlider(
                                            values: currentRangeValues,
                                            min: 0,
                                            max: 60,
                                            divisions: 60,
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
                                        foundResumes(
                                            cityController.text,
                                            skillsController.text,
                                            educationController.text,
                                            currentRangeValues.start.round(),
                                            currentRangeValues.end.round());
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Результаты фильтрации!"),
                                          ),
                                        );
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
            icon: Icon(Icons.filter_alt, color: Colors.white),
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Colors.grey.shade900),
              foregroundColor:
              MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              listResumeSetStatusOk(currentPage, context);
              cityController.clear();
              skillsController.clear();
              educationController.clear();
              currentRangeValues = const RangeValues(0, 60);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Фильтры сброшены!"),
                ),
              );
            },
            icon: Icon(Icons.filter_alt_off, color: Colors.white),
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Colors.grey.shade900),
              foregroundColor:
              MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
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
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: 30.0,
                                icon: Stack(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.red,
                                      size: 30.0,
                                    ),
                                    Icon(
                                      Icons.person,
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileUser(token: widget.token, id: data.user.id, vacancyId: 0)),
                                  );
                                },
                              ),
                              IconButton(
                                iconSize: 30.0,
                                icon: Stack(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 30.0,
                                    ),
                                    Icon(
                                      Icons.favorite_border,
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  createResponseToResume(data.id, context);
                                },
                              )
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