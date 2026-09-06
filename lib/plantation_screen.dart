import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantationItem {
  String farmName;
  String name;
  String description;
  double quantity;
  String unit;
  DateTime plantedDate;
  String maturityPeriod;

  PlantationItem({
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

  Map<String, dynamic> toJson() => {
        'farmName': farmName,
        'name': name,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'plantedDate': plantedDate.toIso8601String(),
        'maturityPeriod': maturityPeriod,
      };

  factory PlantationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return PlantationItem(
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

class PlantationScreen extends StatefulWidget {
  const PlantationScreen({super.key});

  @override
  State<PlantationScreen> createState() =>
      _PlantationScreenState();
}

class _PlantationScreenState extends State<PlantationScreen> {
  static const String storageKey =
      'kyamusoni_plantation_items';

  final List<PlantationItem> _items = [];

  static const units = [
    'kg',
    'bags',
    'acres',
    'pieces',
  ];

  static const maturityOptions = [
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
            (item) => PlantationItem.fromJson(
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

  int daysLeft(PlantationItem item) {
    final days =
        item.harvestDate.difference(DateTime.now()).inDays;

    return days < 0 ? 0 : days;
  }

  void _showForm({PlantationItem? item}) {
    final farm = TextEditingController(
      text: item?.farmName ?? '',
    );
    final name = TextEditingController(
      text: item?.name ?? '',
    );
    final description = TextEditingController(
      text: item?.description ?? '',
    );
    final quantity = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    DateTime planted =
        item?.plantedDate ?? DateTime.now();

    String unit = item?.unit ?? 'kg';
    String? maturity = item?.maturityPeriod;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            DateTime? harvest;

            if (maturity != null) {
              final temp = PlantationItem(
                farmName: '',
                name: '',
                description: '',
                quantity: 0,
                unit: unit,
                plantedDate: planted,
                maturityPeriod: maturity!,
              );

              harvest = temp.harvestDate;
            }

            return AlertDialog(
              title: Text(
                item == null
                    ? 'Add Plantation'
                    : 'Edit Plantation',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: farm,
                      decoration: const InputDecoration(
                        labelText: 'Farm Name',
                      ),
                    ),
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextField(
                      controller: description,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: quantity,
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
                      subtitle: Text(formatDate(planted)),
                      trailing: const Icon(
                        Icons.calendar_today,
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
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Harvest Date: ${formatDate(harvest!)}',
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
                    final parsed =
                        double.tryParse(quantity.text.trim());

                    if (farm.text.trim().isEmpty ||
                        name.text.trim().isEmpty ||
                        parsed == null ||
                        parsed < 0 ||
                        maturity == null) {
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
                        PlantationItem(
                          farmName: farm.text.trim(),
                          name: name.text.trim(),
                          description: description.text.trim(),
                          quantity: parsed,
                          unit: unit,
                          plantedDate: planted,
                          maturityPeriod: maturity!,
                        ),
                      );
                    } else {
                      item.farmName = farm.text.trim();
                      item.name = name.text.trim();
                      item.description = description.text.trim();
                      item.quantity = parsed;
                      item.unit = unit;
                      item.plantedDate = planted;
                      item.maturityPeriod = maturity!;
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
    setState(() => _items.removeAt(index));
    await saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantation'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No plantation items yet.\nTap + to add one.',
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
