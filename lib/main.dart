import 'package:flutter/material.dart';
import 'package:hackathon_app/simple_hub_screen.dart';

void main() {
  runApp(const BankingHubApp());
}



class BankingHubApp extends StatelessWidget {
  const BankingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleHubScreen(),
    );
  }
}

