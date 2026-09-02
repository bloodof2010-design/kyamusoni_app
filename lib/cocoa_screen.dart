import 'package:flutter/material.dart';

class CocoaScreen extends StatelessWidget {
  const CocoaScreen({super.key});

  final List<Map<String, dynamic>> cocoaProducts = const [
    {
      'name': 'Cocoa Beans',
      'description':
          'Quality cocoa beans suitable for processing and chocolate production.',
      'rating': 4.6,
    },
    {
      'name': 'Cocoa Plantation',
      'description':
          'A cocoa farming setup focused on healthy trees, good maintenance, and reliable production.',
      'rating': 4.7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocoa'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cocoaProducts.length,
        itemBuilder: (context, index) {
          final product = cocoaProducts[index];

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
