import 'package:flutter/material.dart';
import 'package:app/router/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人脸管家',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 107, 39, 223),
        ),
      ),
      routes: routeTable,
      initialRoute: RouteNames.splash,
    );
  }
}
