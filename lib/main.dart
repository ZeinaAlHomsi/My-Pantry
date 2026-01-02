import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyPantryApp());
}

class MyPantryApp extends StatelessWidget {
  const MyPantryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPantry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}
