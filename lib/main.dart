import 'package:flutter/material.dart';
import 'taste_screen.dart';

void main() {
  runApp(const KyamusoniApp());
}

class KyamusoniApp extends StatelessWidget {
  const KyamusoniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kyamusoni App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false, // FIXED for Android 5
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kyamusoni'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Kyamusoni App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Explore the Kyamusoni Taste App.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TasteScreen()),
                  );
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Open Taste App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
