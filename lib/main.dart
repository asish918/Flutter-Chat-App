import 'package:chat_app/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData.dark().copyWith(
        colorScheme:
            const ColorScheme.dark().copyWith(background: backgroundColor),
      ),
      home: const Scaffold(
        body: Center(
          child: Text("Hemlo Bimch"),
        ),
      ),
    );
  }
}
