import 'package:flutter/material.dart';

class PlantationScreen extends StatelessWidget {
  const PlantationScreen({super.key});

  final List<Map<String, dynamic>> plantations = const [
    {
      'name': 'Banana Plantation',
      'description':
          'Management template for healthy banana production, field maintenance, and harvesting.',
      'rating': 4.6,
    },
    {
      'name': 'Coffee Plantation',
      'description':
          'Management template for coffee farming, crop maintenance, harvesting, and quality production.',
      'rating': 4.7,
    },
    {
      'name': 'Cocoa Plantation',
      'description':
          'Management template for cocoa farming, tree care, pest control, and improved production.',
      'rating': 4.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantation'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plantations.length,
        itemBuilder: (context, index) {
          final plantation = plantations[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                plantation['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plantation['description']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text('${plantation['rating']}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
