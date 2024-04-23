import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recruitment/PageScreen/UserVacancy.dart';

import 'LK.dart';

class UserPage extends StatelessWidget {
  final String token;
  UserPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добро пожаловать!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LK(token: token)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserVacancy(token: token)));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: IconThemeData(size: 30),
                        child: Icon(Icons.arrow_forward),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Поиск вакансий',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ModerResume(token: token)));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: IconThemeData(size: 30),
                        child: Icon(Icons.arrow_forward),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Создание резюме',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}