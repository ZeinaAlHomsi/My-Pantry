import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isChoosingFood = true;

  int selectedIndex = 0;

  double days = 0;
  String statusText = "";
  String detailsText = "";

  List<String> foods = ["Chicken", "Bread", "Milk"];

  List<String> images = [
    "assets/Chiken.jpg",
    "assets/Bread.jpg",
    "assets/Milk.jpg",
  ];

  Map<String, int> shelfLife = {"Chicken": 5, "Bread": 10, "Milk": 7};

  List<String> storageTypes = ["Room", "Fridge", "Freezer"];
  String selectedStorage = "Room";

  TextEditingController daysController = TextEditingController();

  void goToCalculator(int index) {
    setState(() {
      selectedIndex = index;
      isChoosingFood = false;
      statusText = "";
      detailsText = "";
      daysController.clear();
      days = 0;
      selectedStorage = "Room";
    });
  }

  void goBackToSelection() {
    setState(() {
      isChoosingFood = true;
      statusText = "";
      detailsText = "";
      daysController.clear();
      days = 0;
    });
  }

  void checkFreshness() {
    if (daysController.text.trim().isEmpty) {
      setState(() {
        statusText = "Please enter how many days ago you bought it.";
        detailsText = "";
      });
      return;
    }

    String food = foods[selectedIndex];
    int baseDays = shelfLife[food] ?? 0;

    double factor = 1.0;
    if (selectedStorage == "Fridge") {
      factor = 1.5;
    } else if (selectedStorage == "Freezer") {
      factor = 3.0;
    }

    double maxDays = baseDays * factor;
    double remaining = maxDays - days;

    if (days > maxDays) {
      statusText = "🔴 Expired";
      detailsText =
          "It has been ${days.toStringAsFixed(0)} days.\nRecommended max is about ${maxDays.toStringAsFixed(0)} days for $food in $selectedStorage.";
    } else if (days >= maxDays - 1) {
      statusText = "🟡 Eat Soon";
      detailsText =
          "You are very close to the limit.\nTry to eat the $food today or tomorrow.";
    } else {
      statusText = "🟢 Still Fresh";
      detailsText =
          "You still have about ${remaining.toStringAsFixed(0)} day(s) before it expires.";
    }

    setState(() {});
  }

  void showTips() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Food Safety Tips"),
          content: const Text(
            "- Always check smell and color.\n"
            "- When in doubt, throw it out.\n"
            "- Put cooked food in the fridge within 2 hours.\n"
            "- Do not refreeze food many times.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget buildSelectionScreen() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                "Choose a food to check",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: foods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => goToCalculator(index),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                foods[index],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCalculatorScreen() {
    String food = foods[selectedIndex];
    String image = images[selectedIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    food,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Where do you keep it?",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedStorage,
                    items: storageTypes.map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStorage = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "How many days ago did you buy it?",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        days = double.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: checkFreshness,
                    child: const Text("Check Freshness"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (detailsText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        detailsText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: showTips,
                    child: const Text("Show Safety Tips"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: goBackToSelection,
                    child: const Text("Change Food"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isChoosingFood ? "My Pantry" : "Freshness Calculator"),
        leading: isChoosingFood
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: goBackToSelection,
              ),
      ),
      body: isChoosingFood ? buildSelectionScreen() : buildCalculatorScreen(),
    );
  }
}
