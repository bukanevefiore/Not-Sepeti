import 'package:flutter/material.dart';
import 'package:notsepeti/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    var databaseHelper = DataBaseHelper();
    databaseHelper.kategorileriGetir();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: Text('Flutter Demo Home Page'),
    );
  }
}

