import 'package:flutter/material.dart';

import 'my_home_page.dart';
import 'countdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Shoes App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'SMART SHOE',
        callBackfunction: 0,
      ),
      routes: <String, WidgetBuilder>{
        "/count": (BuildContext context) => new Countdown(),
        // "/myhome": (BuildContext context) => new MyHomePage(
        //       title: 'Smart Shoes',
        //       callBackfunction: 1,
        //     ),
        //add more routes here
      },
    );
  }
}
