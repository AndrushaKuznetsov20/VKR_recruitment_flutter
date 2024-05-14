import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'PageScreen/Home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Подбор персонала',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home()
      },
    );
  }
}