import 'package:flutter/material.dart';

class TasteScreen extends StatelessWidget {
  const TasteScreen({super.key});

  static const List<Map<String, dynamic>> demoFoods = [
    {
      'name': 'Rolex',
      'description': 'Chapati rolled with eggs and vegetables.',
      'rating': 4.8,
    },
    {
      'name': 'Matoke',
      'description': 'A traditional Ugandan banana dish.',
      'rating': 4.6,
    },
    {
      'name': 'Grilled Chicken',
      'description': 'Tender chicken prepared with local spices.',
      'rating': 4.7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taste App'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taste of Kyamusoni',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover popular dishes and explore local tastes.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo Foods',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...demoFoods.map(
            (food) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.restaurant),
                ),
                title: Text(food['name'] as String),
                subtitle: Text(food['description'] as String),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 20),
                    Text('${food['rating']}'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Taste Search'),
              subtitle: const Text(
                'Feature placeholder: search and discover dishes.',
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Taste Search is coming soon.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
