import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LK/LK.dart';
import '../User/UserPage.dart';
import 'EmployerPage.dart';

class CreateVacancy extends StatefulWidget {

  final String token;
  CreateVacancy({required this.token});

  @override
  CreateVacancyState createState() => CreateVacancyState();
}
class CreateVacancyState extends State<CreateVacancy>
{

  final TextEditingController name_vacancyController = TextEditingController();
  final TextEditingController description_vacancyController = TextEditingController();
  final TextEditingController conditions_and_requirementsController = TextEditingController();
  final TextEditingController wageController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();

  Future<void> createVacancy(BuildContext context) async {

    String name_vacancy = name_vacancyController .text;
    String description_vacancy = description_vacancyController.text;
    String conditions_and_requirements = conditions_and_requirementsController.text;
    String wage = wageController.text;
    String schedule = scheduleController.text;

    final url = Uri.parse('http://192.168.0.186:8092/vacancy/create');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'name_vacancy': name_vacancy,
      'description_vacancy': description_vacancy,
      'conditions_and_requirements': conditions_and_requirements,
      'wage': wage,
      'schedule': schedule,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EmployerPage(token: widget.token)));
    }
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }
  final RegExp numRegExp = RegExp(r'^[0-9]*$');
  @override
  void initState() {
    super.initState();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Создание вакансии',
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: name_vacancyController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title, color: Colors.black),
                  labelText: 'Введите наименование:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: description_vacancyController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.description, color: Colors.black),
                  labelText: 'Введите описание:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),

              TextField(
                controller: conditions_and_requirementsController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.assignment_turned_in, color: Colors.black),
                  labelText: 'Введите условия и требования:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: wageController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money, color: Colors.black),
                  labelText: 'Введите размер заработной платы:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number),
              SizedBox(height: 12.0),
              TextField(
                controller: scheduleController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.schedule, color: Colors.black),
                  labelText: 'Введите график работы:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  createVacancy(context);
                },
                child: Text('Создать'),
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
      ),
    );
  }
}