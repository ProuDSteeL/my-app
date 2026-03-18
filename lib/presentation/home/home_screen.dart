import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Главная',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: const Center(
        child: Text('Главная'),
      ),
    );
  }
}
