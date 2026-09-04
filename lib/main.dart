import 'package:flutter/material.dart';
import 'poultry_screen.dart';
import 'maize_screen.dart';
import 'cocoa_screen.dart';
import 'plantation_screen.dart';

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
        useMaterial3: false,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
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

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Kyamusoni App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                      MaterialPageRoute(
                        builder: (_) => const PoultryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.egg),
                  label: const Text('Poultry'),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MaizeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.grass),
                  label: const Text('Maize'),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CocoaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.eco),
                  label: const Text('Cocoa'),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PlantationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.agriculture),
                  label: const Text('Plantation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
