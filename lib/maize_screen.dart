import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaizeItem {
  String farmName;
  String name;
  String description;
  double quantity;
  String unit;
  DateTime plantedDate;
  String maturityPeriod;

  MaizeItem({
    required this.farmName,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.plantedDate,
    required this.maturityPeriod,
  });

  DateTime get harvestDate {
    switch (maturityPeriod) {
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

  Map<String, dynamic> toJson() {
    return {
      'farmName': farmName,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'plantedDate': plantedDate.toIso8601String(),
      'maturityPeriod': maturityPeriod,
    };
  }

  factory MaizeItem.fromJson(Map<String, dynamic> json) {
    return MaizeItem(
      farmName: json['farmName'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] ?? 'kg',
      plantedDate: DateTime.parse(json['plantedDate']),
      maturityPeriod: json['maturityPeriod'] ?? '90 days',
    );
  }
}

class MaizeScreen extends StatefulWidget {
  const MaizeScreen({super.key});

  @override
  State<MaizeScreen> createState() => _MaizeScreenState();
}

class _MaizeScreenState extends State<MaizeScreen> {
  static const String storageKey = 'kyamusoni_maize_items';

  final List<MaizeItem> _items = [];

  static const List<String> units = [
    'kg',
    'bags',
    'acres',
    'pieces',
  ];

  static const List<String> maturityOptions = [
    '30 days',
    '60 days',
    '90 days',
    '6 months',
    '9 months',
    '12 months',
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);

    if (saved == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(saved);

      setState(() {
        _items.clear();
        _items.addAll(
          decoded.map(
            (item) => MaizeItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          ),
        );
      });
    } catch (_) {}
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      storageKey,
      jsonEncode(
        _items.map((item) => item.toJson()).toList(),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int daysLeft(MaizeItem item) {
    final days =
        item.harvestDate.difference(DateTime.now()).inDays;

    return days < 0 ? 0 : days;
  }

  void _showForm({MaizeItem? item}) {
    final farmController =
        TextEditingController(text: item?.farmName ?? '');

    final nameController =
        TextEditingController(text: item?.name ?? '');

    final descriptionController =
        TextEditingController(text: item?.description ?? '');

    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    DateTime plantedDate =
        item?.plantedDate ?? DateTime.now();

    String unit = item?.unit ?? 'kg';
    String? maturityPeriod = item?.maturityPeriod;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            DateTime? harvestDate;

            if (maturityPeriod != null) {
              final temp = MaizeItem(
                farmName: '',
                name: '',
                description: '',
                quantity: 0,
                unit: unit,
                plantedDate: plantedDate,
                maturityPeriod: maturityPeriod!,
              );

              harvestDate = temp.harvestDate;
            }

            return AlertDialog(
              title: Text(
                item == null ? 'Add Maize' : 'Edit Maize',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: farmController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Name',
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: units.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => unit = value);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Planted Date'),
                      subtitle: Text(
                        formatDate(plantedDate),
                      ),
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
                    DropdownButtonFormField<String>(
                      value: maturityPeriod,
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
                        setDialogState(
                          () => maturityPeriod = value,
                        );
                      },
                    ),
                    if (harvestDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Harvest Date: ${formatDate(harvestDate!)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final quantity = double.tryParse(
                      quantityController.text.trim(),
                    );

                    if (farmController.text.trim().isEmpty ||
                        nameController.text.trim().isEmpty ||
                        quantity == null ||
                        quantity < 0 ||
                        maturityPeriod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Farm Name, Name, Quantity and Maturity Period are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (item == null) {
                      _items.add(
                        MaizeItem(
                          farmName: farmController.text.trim(),
                          name: nameController.text.trim(),
                          description:
                              descriptionController.text.trim(),
                          quantity: quantity,
                          unit: unit,
                          plantedDate: plantedDate,
                          maturityPeriod: maturityPeriod!,
                        ),
                      );
                    } else {
                      item.farmName = farmController.text.trim();
                      item.name = nameController.text.trim();
                      item.description =
                          descriptionController.text.trim();
                      item.quantity = quantity;
                      item.unit = unit;
                      item.plantedDate = plantedDate;
                      item.maturityPeriod = maturityPeriod!;
                    }

                    await saveItems();

                    if (!mounted) return;

                    setState(() {});
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    item == null ? 'Add' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });

    await saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maize'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No maize items yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];

                final ready = !DateTime.now()
                    .isBefore(item.harvestDate);

                return Card(
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Farm: ${item.farmName}\n'
                      '${item.description}\n'
                      'Quantity: ${item.quantity} ${item.unit}\n'
                      'Planted: ${formatDate(item.plantedDate)}\n'
                      'Harvest: ${formatDate(item.harvestDate)}\n'
                      '${ready ? 'Ready' : 'Growing - ${daysLeft(item)} days left'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showForm(item: item);
                        } else {
                          _deleteItem(index);
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
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
