import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/pantry_item.dart';
import 'add_edit_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PantryItem> _items = [];
  static const String _apiBaseUrl =
      "http://127.0.0.1/MyPantry_api/MyPantry_api.php";
  PantryCategory? _selectedCategory; // null = All

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Uri _uri(Map<String, String> q) =>
      Uri.parse(_apiBaseUrl).replace(queryParameters: q);

  PantryItem _fromJson(Map<String, dynamic> j) {
    return PantryItem(
      id: j["id"].toString(),
      name: j["name"].toString(),
      amount: (j["amount"] as num).toDouble(),
      category: categoryFromInt((j["category"] as num).toInt()),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(
        (j["expiryDate"] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> _toJson(PantryItem item) {
    return {
      "id": item.id,
      "name": item.name,
      "amount": item.amount,
      "category": item.category.index,
      "expiryDate": item.expiryDate.millisecondsSinceEpoch,
    };
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);

    try {
      final params = <String, String>{"action": "items"};
      if (_selectedCategory != null) {
        params["category"] = _selectedCategory!.index.toString();
      }

      final res = await http.get(_uri(params));
      if (res.statusCode != 200) {
        throw Exception("GET items failed: ${res.statusCode} ${res.body}");
      }

      final list = jsonDecode(res.body) as List<dynamic>;
      final items = list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _items = items; // already sorted by expiry from API
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load items: $e")));
    }
  }

  Future<void> _addItem(PantryItem item) async {
    final res = await http.post(
      _uri({"action": "add"}),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(_toJson(item)),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception("POST add failed: ${res.statusCode} ${res.body}");
    }
  }

  Future<void> _updateItem(PantryItem item) async {
    final res = await http.put(
      _uri({"action": "update", "id": item.id}),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": item.name,
        "amount": item.amount,
        "category": item.category.index,
        "expiryDate": item.expiryDate.millisecondsSinceEpoch,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("PUT update failed: ${res.statusCode} ${res.body}");
    }
  }

  Future<void> _deleteItem(String id) async {
    final res = await http.delete(_uri({"action": "delete", "id": id}));
    if (res.statusCode != 200) {
      throw Exception("DELETE failed: ${res.statusCode} ${res.body}");
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  int _daysLeft(DateTime expiry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiry.year, expiry.month, expiry.day);
    return exp.difference(today).inDays;
  }

  Future<void> _goAdd() async {
    final result = await Navigator.push<PantryItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditItemPage()),
    );

    if (result != null) {
      try {
        await _addItem(result);
        await _loadItems();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to add: $e")));
      }
    }
  }

  Future<void> _goEdit(PantryItem item) async {
    final result = await Navigator.push<PantryItem>(
      context,
      MaterialPageRoute(builder: (_) => AddEditItemPage(existing: item)),
    );

    if (result != null) {
      try {
        await _updateItem(result);
        await _loadItems();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
      }
    }
  }

  Future<void> _delete(PantryItem item) async {
    try {
      await _deleteItem(item.id);
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    }
  }

  //here ends the api calls
  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MyPantry"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goAdd,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Category: "),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<PantryCategory?>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<PantryCategory?>(
                        value: null,
                        child: Text("All"),
                      ),
                      ...PantryCategory.values.map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(categoryLabel(c)),
                        ),
                      ),
                    ],
                    onChanged: (v) async {
                      setState(() => _selectedCategory = v);
                      await _loadItems();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? const Center(
                      child: Text("No items yet. Add your first item!"),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final days = _daysLeft(item.expiryDate);

                        String status;
                        if (days < 0) {
                          status = "Expired ${days.abs()} day(s) ago";
                        } else if (days == 0) {
                          status = "Expires today";
                        } else {
                          status = "Expires in $days day(s)";
                        }

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: "Edit",
                                    onPressed: () => _goEdit(item),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    tooltip: "Delete",
                                    onPressed: () => _delete(item),
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("Amount: ${item.amount}"),
                              Text("Category: ${categoryLabel(item.category)}"),
                              Text("Expiry: ${_formatDate(item.expiryDate)}"),
                              const SizedBox(height: 6),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
