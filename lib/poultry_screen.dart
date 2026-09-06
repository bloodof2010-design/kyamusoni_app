import 'package:flutter/material.dart';

class PoultryItem {
  String name;
  String description;
  int quantity;
  DateTime plantedDate;
  String maturityPeriod;

  PoultryItem({
    required this.name,
    required this.description,
    required this.quantity,
    required this.plantedDate,
    required this.maturityPeriod,
  });

  DateTime get expectedHarvestDate {
    return calculateHarvestDate(plantedDate, maturityPeriod);
  }

  bool get isReady {
    return !DateTime.now().isBefore(expectedHarvestDate);
  }
}

class PoultryScreen extends StatefulWidget {
  const PoultryScreen({super.key});

  @override
  State<PoultryScreen> createState() => _PoultryScreenState();
}

class _PoultryScreenState extends State<PoultryScreen> {
  final List<PoultryItem> _items = [];

  static const List<String> maturityOptions = [
    '30 days',
    '60 days',
    '90 days',
    '6 months',
    '9 months',
    '12 months',
  ];

  DateTime calculateHarvestDate(DateTime plantedDate, String maturity) {
    switch (maturity) {
      case '30 days':
        return plantedDate.add(const Duration(days: 30));
      case '60 days':
        return plantedDate.add(const Duration(days: 60));
      case '90 days':
        return plantedDate.add(const Duration(days: 90));
      case '6 months':
        return DateTime(
          plantedDate.year,
          plantedDate.month + 6,
          plantedDate.day,
        );
      case '9 months':
        return DateTime(
          plantedDate.year,
          plantedDate.month + 9,
          plantedDate.day,
        );
      case '12 months':
        return DateTime(
          plantedDate.year + 1,
          plantedDate.month,
          plantedDate.day,
        );
      default:
        return plantedDate;
    }
  }

  int daysLeft(PoultryItem item) {
    final difference =
        item.expectedHarvestDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  void _showItemForm({PoultryItem? item}) {
    final nameController = TextEditingController(
      text: item?.name ?? '',
    );
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    DateTime plantedDate = item?.plantedDate ?? DateTime.now();
    String? maturityPeriod = item?.maturityPeriod;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final harvestDate = maturityPeriod == null
                ? null
                : calculateHarvestDate(
                    plantedDate,
                    maturityPeriod!,
                  );

            return AlertDialog(
              title: Text(item == null ? 'Add Poultry Item' : 'Edit Poultry Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Planted Date'),
                      subtitle: Text(
                        '${plantedDate.day}/${plantedDate.month}/${plantedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: plantedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selected != null) {
                          setDialogState(() {
                            plantedDate = selected;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: maturityPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Maturity Period *',
                      ),
                      items: maturityOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          maturityPeriod = value;
                        });
                      },
                    ),
                    if (harvestDate != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Expected Harvest: '
                          '${harvestDate.day}/${harvestDate.month}/${harvestDate.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final quantity =
                        int.tryParse(quantityController.text.trim());

                    if (name.isEmpty ||
                        quantity == null ||
                        quantity < 0 ||
                        maturityPeriod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter Name, valid Quantity and Maturity Period.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (item == null) {
                        _items.add(
                          PoultryItem(
                            name: name,
                            description: descriptionController.text.trim(),
                            quantity: quantity,
                            plantedDate: plantedDate,
                            maturityPeriod: maturityPeriod!,
                          ),
                        );
                      } else {
                        item.name = name;
                        item.description =
                            descriptionController.text.trim();
                        item.quantity = quantity;
                        item.plantedDate = plantedDate;
                        item.maturityPeriod = maturityPeriod!;
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(item == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poultry'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('No poultry items yet. Tap + to add one.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final ready = item.isReady;

                return Card(
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.description}\n'
                      'Quantity: ${item.quantity}\n'
                      'Planted: ${item.plantedDate.day}/${item.plantedDate.month}/${item.plantedDate.year}\n'
                      'Harvest: ${item.expectedHarvestDate.day}/${item.expectedHarvestDate.month}/${item.expectedHarvestDate.year}\n'
                      '${ready ? 'Ready' : 'Growing - ${daysLeft(item)} days left'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showItemForm(item: item);
                        } else if (value == 'delete') {
                          setState(() {
                            _items.removeAt(index);
                          });
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

DateTime calculateHarvestDate(DateTime plantedDate, String maturity) {
  switch (maturity) {
    case '30 days':
      return plantedDate.add(const Duration(days: 30));
    case '60 days':
      return plantedDate.add(const Duration(days: 60));
    case '90 days':
      return plantedDate.add(const Duration(days: 90));
    case '6 months':
      return DateTime(plantedDate.year, plantedDate.month + 6, plantedDate.day);
    case '9 months':
      return DateTime(plantedDate.year, plantedDate.month + 9, plantedDate.day);
    case '12 months':
      return DateTime(plantedDate.year + 1, plantedDate.month, plantedDate.day);
    default:
      return plantedDate;
  }
}
