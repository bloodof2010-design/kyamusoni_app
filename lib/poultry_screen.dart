import 'package:flutter/material.dart';

class PoultryScreen extends StatelessWidget {
  const PoultryScreen({super.key});

  final List<Map<String, dynamic>> poultryProducts = const [
    {
      'name': 'Broilers',
      'description':
          'Fast-growing chickens raised mainly for quality meat production.',
      'rating': 4.5,
    },
    {
      'name': 'Layers',
      'description':
          'Chickens bred and managed primarily for consistent egg production.',
      'rating': 4.7,
    },
    {
      'name': 'Kuroilers',
      'description':
          'Hardy dual-purpose birds suitable for both meat and egg production.',
      'rating': 4.6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poultry'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: poultryProducts.length,
        itemBuilder: (context, index) {
          final product = poultryProducts[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                product['name'],
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
                    Text(product['description']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text('${product['rating']}'),
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
