import 'package:flutter/material.dart';

class CocoaItem {
  String name;
  String description;
  int quantity;
  DateTime plantedDate;
  String maturityPeriod;

  CocoaItem({
    required this.name,
    required this.description,
    required this.quantity,
    required this.plantedDate,
    required this.maturityPeriod,
  });

  DateTime get expectedHarvestDate =>
      calculateCocoaHarvestDate(plantedDate, maturityPeriod);

  bool get isReady => !DateTime.now().isBefore(expectedHarvestDate);
}

class CocoaScreen extends StatefulWidget {
  const CocoaScreen({super.key});

  @override
  State<CocoaScreen> createState() => _CocoaScreenState();
}

class _CocoaScreenState extends State<CocoaScreen> {
  final List<CocoaItem> _items = [];

  static const maturityOptions = [
    '30 days',
    '60 days',
    '90 days',
    '6 months',
    '9 months',
    '12 months',
  ];

  int _daysLeft(CocoaItem item) {
    final days =
        item.expectedHarvestDate.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  void _showForm({CocoaItem? item}) {
    final name = TextEditingController(text: item?.name ?? '');
    final description =
        TextEditingController(text: item?.description ?? '');
    final quantity =
        TextEditingController(text: item?.quantity.toString() ?? '');

    DateTime planted = item?.plantedDate ?? DateTime.now();
    String? maturity = item?.maturityPeriod;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            DateTime? harvest = maturity == null
                ? null
                : calculateCocoaHarvestDate(planted, maturity!);

            return AlertDialog(
              title: Text(item == null ? 'Add Cocoa Item' : 'Edit Cocoa Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: description,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Quantity'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Planted Date'),
                      subtitle: Text(
                        '${planted.day}/${planted.month}/${planted.year}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: planted,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          setDialogState(() => planted = date);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: maturity,
                      decoration: const InputDecoration(
                        labelText: 'Maturity Period *',
                      ),
                      items: maturityOptions.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => maturity = value);
                      },
                    ),
                    if (harvest != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Expected Harvest: '
                            '${harvest.day}/${harvest.month}/${harvest.year}',
                          ),
                        ),
                      ),
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
                    final parsedQuantity =
                        int.tryParse(quantity.text.trim());

                    if (name.text.trim().isEmpty ||
                        parsedQuantity == null ||
                        parsedQuantity < 0 ||
                        maturity == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Name, valid Quantity and Maturity Period are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (item == null) {
                        _items.add(
                          CocoaItem(
                            name: name.text.trim(),
                            description: description.text.trim(),
                            quantity: parsedQuantity,
                            plantedDate: planted,
                            maturityPeriod: maturity!,
                          ),
                        );
                      } else {
                        item.name = name.text.trim();
                        item.description = description.text.trim();
                        item.quantity = parsedQuantity;
                        item.plantedDate = planted;
                        item.maturityPeriod = maturity!;
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
      appBar: AppBar(title: const Text('Cocoa')),
      body: _items.isEmpty
          ? const Center(child: Text('No cocoa items yet. Tap + to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];

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
                      '${item.isReady ? 'Ready' : 'Growing - ${_daysLeft(item)} days left'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showForm(item: item);
                        } else {
                          setState(() => _items.removeAt(index));
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
        onPressed: _showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

DateTime calculateCocoaHarvestDate(
  DateTime plantedDate,
  String maturity,
) {
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
