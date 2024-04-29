import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LK/LK.dart';
import '../User/UserPage.dart';

class CreateResume extends StatefulWidget {

  final String token;
  CreateResume ({required this.token});

  @override
  CreateResumeState createState() => CreateResumeState();
}
class CreateResumeState extends State<CreateResume>
{

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController otherInfoController = TextEditingController();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Выберите дату',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      // locale: const Locale('ru'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthDateController.text = dateFormat.format(picked);
      });
    }
  }

  Future<void> createResume(BuildContext context) async {
    String fullName =fullNameController.text;
    String birthDate = birthDateController.text;
    String city = cityController.text;
    String skills = skillsController.text;
    String education = educationController.text;
    String otherInfo = otherInfoController.text;

    final url = Uri.parse('http://172.20.10.3:8092/resume/create');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'fullName': fullName,
      'birthDate': birthDate,
      'city': city,
      'skills': skills,
      'education': education,
      'otherInfo': otherInfo,
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
              builder: (context) => UserPage(token: widget.token)));
    }
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Создание резюме',
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  labelText: 'Введите ФИО:',
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
                controller: birthDateController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                  labelText: 'Выберите дату рождения:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                    color: Colors.black,
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
                readOnly: true,
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_city, color: Colors.black),
                  labelText: 'Введите город:',
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
                controller: skillsController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.work, color: Colors.black),
                  labelText: 'Введите навыки:',
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
                controller: educationController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.school, color: Colors.black),
                  labelText: 'Введите образование:',
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
                controller: otherInfoController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info, color: Colors.black),
                  labelText: 'Введите доп. информацию:',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: () {
                  createResume(context);
                },
                icon: Icon(Icons.add),
                label: Text('Создать'),
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