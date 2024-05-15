import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../Models/Resume.dart';
import '../Home.dart';
import '../LK/LK.dart';
import 'ReadMyResume.dart';

class UpdateResume extends StatefulWidget {
  final String token;
  final int id;
  final String fullName;
  final DateTime birthDate;
  final String city;
  final String skills;
  final String education;
  final String otherInfo;

  UpdateResume({required this.token, required this.id,
    required this.fullName, required this.birthDate, required this.city,
    required this.skills, required this.education, required this.otherInfo});

  @override
  UpdateResumeState createState() => UpdateResumeState();
}
class UpdateResumeState extends State<UpdateResume> {
  late TextEditingController fullNameController;
  late TextEditingController birthDateController;
  late TextEditingController cityController;
  late TextEditingController skillsController;
  late TextEditingController educationController;
  late TextEditingController otherInfoController;

  Resume? resume;

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

  Future<void> updateDataResume(BuildContext context) async
  {
    String fullName = fullNameController.text;
    String birthDate = birthDateController.text;
    String city = cityController.text;
    String skills = skillsController.text;
    String education = educationController.text;
    String otherInfo = otherInfoController.text;

    final url = Uri.parse('http://172.20.10.3:8092/resume/update/${widget.id}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'
    };
    final body = jsonEncode({
      'fullName': fullName,
      'birthDate': birthDate,
      'city': city,
      'skills': skills,
      'education': education,
      'otherInfo': otherInfo,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => LK(token: widget.token)));
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
  }

  Future<Resume?> findByUserResume() async
  {
    final response = await http.get(
      Uri.parse('http://192.168.0.186:8092/resume/myResume'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        resume = Resume.fromJson(jsonData);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: utf8.decode(widget.fullName.codeUnits));
    birthDateController = TextEditingController(text: dateFormat.format(widget.birthDate));
    cityController = TextEditingController(text: utf8.decode(widget.city.codeUnits));
    skillsController = TextEditingController(text: utf8.decode(widget.skills.codeUnits));
    educationController = TextEditingController(text: utf8.decode(widget.education.codeUnits));
    otherInfoController = TextEditingController(text: utf8.decode(widget.otherInfo.codeUnits));
    findByUserResume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование резюме',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
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
                controller: fullNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  labelText: 'Введите новое ФИО',
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
                controller: birthDateController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                  labelText: 'Выберите новую дату рождения:',
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
                  labelText: 'Введите новый город:',
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
                controller: skillsController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.work, color: Colors.black),
                  labelText: 'Введите новые навыки:',
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
                controller: educationController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.school, color: Colors.black),
                  labelText: 'Введите новое образование:',
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
                controller: otherInfoController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info, color: Colors.black),
                  labelText: 'Введите новую доп. информацию:',
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
                    updateDataResume(context);
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
