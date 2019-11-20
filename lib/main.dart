import 'package:flutter/material.dart';
import 'package:starter_kit/pages/landing_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starter Kit',
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}
