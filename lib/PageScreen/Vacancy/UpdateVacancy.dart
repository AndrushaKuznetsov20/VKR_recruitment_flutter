import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../Models/Vacancy.dart';
import '../Home.dart';
import '../LK/LK.dart';
import 'ReadMyVacancy.dart';

class UpdateVacancy extends StatefulWidget {
  final String token;
  final int id;
  final String name_vacancy;
  final String description_vacancy;
  final String conditions_and_requirements;
  final int wage;
  final String schedule;

  UpdateVacancy({required this.token, required this.id, required this.name_vacancy,
    required this.description_vacancy, required this.conditions_and_requirements,
  required this.wage, required this.schedule});

  @override
  UpdateVacancyState createState() => UpdateVacancyState();
}
class UpdateVacancyState extends State<UpdateVacancy> {
  late TextEditingController name_vacancyController;
  late TextEditingController description_vacancyController;
  late TextEditingController conditions_and_requirementsController;
  late TextEditingController wageController;
  late TextEditingController scheduleController;

  Future<void> updateDataVacancy(BuildContext context) async
  {
    String name_vacancy = name_vacancyController.text;
    String description_vacancy = description_vacancyController.text;
    String conditions_and_requirements = conditions_and_requirementsController.text;
    String wage = wageController.text;
    String schedule = scheduleController.text;

    final url = Uri.parse('http://172.20.10.3:8092/vacancy/update/${widget.id}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };
    final body = jsonEncode({
      'name_vacancy': name_vacancy,
      'description_vacancy': description_vacancy,
      'conditions_and_requirements': conditions_and_requirements,
      'wage': wage,
      'schedule': schedule,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    else {
      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
          ),
        );
        Navigator.of(context).pop();
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReadMyVacancy(token: widget.token)));
  }

  final RegExp numRegExp = RegExp(r'^[0-9]*$');
  @override
  void initState() {
    super.initState();
    name_vacancyController = TextEditingController(text: utf8.decode(widget.name_vacancy.codeUnits));
    description_vacancyController = TextEditingController(text: utf8.decode(widget.description_vacancy.codeUnits));
    conditions_and_requirementsController = TextEditingController(text: utf8.decode(widget.conditions_and_requirements.codeUnits));
    wageController = TextEditingController(text: widget.wage.toString());
    scheduleController = TextEditingController(text: utf8.decode(widget.schedule.codeUnits));

    wageController.addListener(() {
      if (!numRegExp.hasMatch(wageController.text)) {
        int selectionStart = wageController.selection.baseOffset - 1;
        wageController.text = wageController.text.replaceAll(RegExp(r'\D'), '');
        wageController.selection =
            TextSelection.fromPosition(TextPosition(offset: selectionStart));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование вакансии',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReadMyVacancy(token: widget.token)));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 12),
                TextField(
                  controller: name_vacancyController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.title, color: Colors.black),
                    labelText: 'Введите новое наименование',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: null,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: description_vacancyController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.description, color: Colors.black),
                    labelText: 'Введите новое описание:',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: null,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: conditions_and_requirementsController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.assignment_turned_in, color: Colors.black),
                    labelText: 'Введите новые условия и требования:',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: null,
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: wageController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.attach_money, color: Colors.black),
                    labelText: 'Введите новую заработную плату:',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: null,
                  keyboardType: TextInputType.number
                ),
                SizedBox(height: 12.0),
                TextField(
                  controller: scheduleController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.schedule, color: Colors.black),
                    labelText: 'Введите новый график:',
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  maxLines: null,
                ),
                SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: () {
                    updateDataVacancy(context);
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Обновить данные'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}