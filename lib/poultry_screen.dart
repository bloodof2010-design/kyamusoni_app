import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoultryItem {
  String farmName;
  String name;
  double quantity;
  String unit;
  String acquisitionType;
  DateTime acquisitionDate;
  String maturityPeriod;

  PoultryItem({
    required this.farmName,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.acquisitionType,
    required this.acquisitionDate,
    required this.maturityPeriod,
  });

  DateTime get readyDate {
    switch (maturityPeriod) {
      case '21 days':
        return acquisitionDate.add(const Duration(days: 21));
      case '6 weeks':
        return acquisitionDate.add(const Duration(days: 42));
      case '18 weeks':
        return acquisitionDate.add(const Duration(days: 126));
      case '6 months':
        return DateTime(
          acquisitionDate.year,
          acquisitionDate.month + 6,
          acquisitionDate.day,
        );
      default:
        return acquisitionDate;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'farmName': farmName,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'acquisitionType': acquisitionType,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'maturityPeriod': maturityPeriod,
    };
  }

  factory PoultryItem.fromJson(Map<String, dynamic> json) {
    return PoultryItem(
      farmName: json['farmName'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] ?? 'pieces',
      acquisitionType: json['acquisitionType'] ?? 'Bought',
      acquisitionDate: DateTime.parse(json['acquisitionDate']),
      maturityPeriod: json['maturityPeriod'] ?? '21 days',
    );
  }
}

class PoultryScreen extends StatefulWidget {
  const PoultryScreen({super.key});

  @override
  State<PoultryScreen> createState() => _PoultryScreenState();
}

class _PoultryScreenState extends State<PoultryScreen> {
  static const String storageKey = 'kyamusoni_poultry_items';

  final List<PoultryItem> _items = [];

  static const List<String> units = [
    'pieces',
    'trays (eggs)',
    'kg',
  ];

  static const List<String> acquisitionTypes = [
    'Bought',
    'Hatched',
  ];

  static const List<String> maturityOptions = [
    '21 days',
    '6 weeks',
    '18 weeks',
    '6 months',
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);

    if (saved == null) {
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(saved);

      setState(() {
        _items.clear();
        _items.addAll(
          decoded.map(
            (item) => PoultryItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          ),
        );
      });
    } catch (_) {
      // Ignore invalid saved data.
    }
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _items.map((item) => item.toJson()).toList();

    await prefs.setString(
      storageKey,
      jsonEncode(data),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int daysLeft(PoultryItem item) {
    final difference = item.readyDate.difference(DateTime.now()).inDays;

    return difference < 0 ? 0 : difference;
  }

  void _showForm({PoultryItem? item}) {
    final farmController = TextEditingController(
      text: item?.farmName ?? '',
    );

    final nameController = TextEditingController(
      text: item?.name ?? '',
    );

    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );

    DateTime acquisitionDate =
        item?.acquisitionDate ?? DateTime.now();

    String unit = item?.unit ?? 'pieces';
    String acquisitionType =
        item?.acquisitionType ?? 'Bought';
    String? maturityPeriod = item?.maturityPeriod;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            DateTime? readyDate;

            if (maturityPeriod != null) {
              final temporaryItem = PoultryItem(
                farmName: '',
                name: '',
                quantity: 0,
                unit: unit,
                acquisitionType: acquisitionType,
                acquisitionDate: acquisitionDate,
                maturityPeriod: maturityPeriod!,
              );

              readyDate = temporaryItem.readyDate;
            }

            return AlertDialog(
              title: Text(
                item == null
                    ? 'Add Poultry'
                    : 'Edit Poultry',
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
                        hintText: 'Broilers, Layers',
                      ),
                    ),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          setDialogState(() {
                            unit = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: acquisitionType,
                      decoration: const InputDecoration(
                        labelText: 'Acquisition Type',
                      ),
                      items: acquisitionTypes.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            acquisitionType = value;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Acquisition Date'),
                      subtitle: Text(
                        formatDate(acquisitionDate),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                      ),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: acquisitionDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (selected != null) {
                          setDialogState(() {
                            acquisitionDate = selected;
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
                        setDialogState(() {
                          maturityPeriod = value;
                        });
                      },
                    ),
                    if (readyDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ready Date: ${formatDate(readyDate!)}',
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
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
                        PoultryItem(
                          farmName: farmController.text.trim(),
                          name: nameController.text.trim(),
                          quantity: quantity,
                          unit: unit,
                          acquisitionType: acquisitionType,
                          acquisitionDate: acquisitionDate,
                          maturityPeriod: maturityPeriod!,
                        ),
                      );
                    } else {
                      item.farmName = farmController.text.trim();
                      item.name = nameController.text.trim();
                      item.quantity = quantity;
                      item.unit = unit;
                      item.acquisitionType = acquisitionType;
                      item.acquisitionDate = acquisitionDate;
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
        title: const Text('Poultry'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'No poultry items yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final ready = !DateTime.now()
                    .isBefore(item.readyDate);

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
                      'Quantity: ${item.quantity} ${item.unit}\n'
                      'Acquisition: ${item.acquisitionType}\n'
                      'Date: ${formatDate(item.acquisitionDate)}\n'
                      'Ready: ${formatDate(item.readyDate)}\n'
                      '${ready ? 'Ready' : 'Growing - ${daysLeft(item)} days left'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showForm(item: item);
                        } else if (value == 'delete') {
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
