import 'package:flutter/material.dart';
import '../models/pantry_item.dart';

class AddEditItemPage extends StatefulWidget {
  final PantryItem? existing;

  const AddEditItemPage({super.key, this.existing});

  @override
  State<AddEditItemPage> createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  PantryCategory _category = PantryCategory.fruits;
  DateTime? _expiry;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.existing?.name ?? "");
    _amountCtrl = TextEditingController(
      text: widget.existing == null ? "" : widget.existing!.amount.toString(),
    );
    _category = widget.existing?.category ?? PantryCategory.fruits;
    _expiry = widget.existing?.expiryDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _expiry ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() => _expiry = DateTime(picked.year, picked.month, picked.day));
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_expiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose an expiry date")),
      );
      return;
    }

    final item = PantryItem(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      expiryDate: _expiry!,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Item" : "Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Name is required";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return "Amount is required";
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0)
                    return "Enter a valid amount";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PantryCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: PantryCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(categoryLabel(c)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Expiry date",
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiry == null ? "Select date" : _formatDate(_expiry!),
                      ),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _save,
                child: Text(isEdit ? "Save Changes" : "Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
