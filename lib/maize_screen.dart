import 'package:flutter/material.dart';

class MaizeScreen extends StatelessWidget {
  const MaizeScreen({super.key});

  final List<Map<String, dynamic>> maizeVarieties = const [
    {
      'name': 'Longe 5',
      'description':
          'A popular maize variety known for good yield and adaptability.',
      'rating': 4.5,
    },
    {
      'name': 'Longe 10H',
      'description':
          'A high-performing maize variety suitable for different growing conditions.',
      'rating': 4.7,
    },
    {
      'name': 'Bazooka',
      'description':
          'A productive maize variety valued for strong performance and good harvests.',
      'rating': 4.6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maize'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: maizeVarieties.length,
        itemBuilder: (context, index) {
          final variety = maizeVarieties[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                variety['name'],
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
                    Text(variety['description']),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text('${variety['rating']}'),
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
