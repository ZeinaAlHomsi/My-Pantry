enum PantryCategory { fruits, vegetables, nuts, breadPasta }

String categoryLabel(PantryCategory c) {
  switch (c) {
    case PantryCategory.fruits:
      return "Fruits";
    case PantryCategory.vegetables:
      return "Vegetables";
    case PantryCategory.nuts:
      return "Nuts";
    case PantryCategory.breadPasta:
      return "Bread & Pasta";
  }
}

PantryCategory categoryFromInt(int v) {
  if (v < 0 || v >= PantryCategory.values.length) return PantryCategory.fruits;
  return PantryCategory.values[v];
}

class PantryItem {
  final String id;
  String name;
  double amount;
  PantryCategory category;
  DateTime expiryDate;

  PantryItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.expiryDate,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category.index,
    'expiryDate': expiryDate.millisecondsSinceEpoch,
  };

  static PantryItem fromMap(Map<String, Object?> map) {
    return PantryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: categoryFromInt(map['category'] as int),
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int),
    );
  }
}
