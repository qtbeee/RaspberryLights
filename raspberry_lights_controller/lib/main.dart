import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/screens/home.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Controller',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
      home: const Home(title: 'Lights Controller'),
    );
  }
}
