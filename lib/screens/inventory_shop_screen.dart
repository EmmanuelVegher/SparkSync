import 'package:flutter/material.dart';

class InventoryShopScreen extends StatefulWidget {
  const InventoryShopScreen({super.key});

  @override
  State<InventoryShopScreen> createState() => _InventoryShopScreenState();
}

class _InventoryShopScreenState extends State<InventoryShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int userWallet = 850;
  int userEnergy = 45;

  // Local Data State Representation of User Inventory
  final Map<int, int> _ownedInventory = {1: 3, 2: 0, 3: 1};

  // Static Items Dictionary Data Array
  final List<Map<String, dynamic>> _consumablesDict = [
    {
      "id": 1,
      "name": "🥩 Suya Platter Special",
      "cost": 40,
      "restore": 25,
      "desc": "Grilled local steak. Restores 25 Energy.",
    },
    {
      "id": 2,
      "name": "🧃 Chilled Malt Drink",
      "cost": 20,
      "restore": 10,
      "desc": "Ice cold premium beverage. Restores 10 Energy.",
    },
    {
      "id": 3,
      "name": "🍲 Jollof Rice & Chicken",
      "cost": 75,
      "restore": 50,
      "desc": "Full party meal package. Restores 50 Energy.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyItem(Map<String, dynamic> item) {
    if (userWallet < (item['cost'] as int)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Not enough coins!"),
        ),
      );
      return;
    }
    setState(() {
      userWallet -= item['cost'] as int;
      _ownedInventory[item['id'] as int] =
          (_ownedInventory[item['id'] as int] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Bought ${item['name']}! Added to your bag.",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _consumeItem(Map<String, dynamic> item) {
    final int currentStock = _ownedInventory[item['id'] as int] ?? 0;
    if (currentStock <= 0) return;
    if (userEnergy >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blueAccent,
          content: Text("Your energy is already full!"),
        ),
      );
      return;
    }

    setState(() {
      _ownedInventory[item['id'] as int] = currentStock - 1;
      userEnergy = ((userEnergy + (item['restore'] as int))).clamp(0, 100);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(
          "Ate ${item['name']}. Energy is now $userEnergy%",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        title: const Text(
          "Shop & Items",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.cyanAccent,
          tabs: const [
            Tab(text: "🏪 STORE"),
            Tab(text: "🎒 MY BAG"),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "🪙 $userWallet Coins  |  ⚡ $userEnergy% Energy",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildShopTab(), _buildInventoryTab()],
      ),
    );
  }

  Widget _buildShopTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consumablesDict.length,
      itemBuilder: (context, index) {
        final item = _consumablesDict[index];
        return Card(
          color: const Color(0xFF16162A),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              item['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item['desc'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              onPressed: () => _buyItem(item),
              child: Text(
                "🪙 ${item['cost']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    final activeItems = _consumablesDict
        .where((item) => (_ownedInventory[item['id'] as int] ?? 0) > 0)
        .toList();

    if (activeItems.isEmpty) {
      return const Center(
        child: Text(
          "Your backpack is empty.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeItems.length,
      itemBuilder: (context, index) {
        final item = activeItems[index];
        final count = _ownedInventory[item['id'] as int];
        return Card(
          color: const Color(0xFF16162A),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              item['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Owned Quantity: $count",
              style: const TextStyle(color: Colors.cyanAccent),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              onPressed: () => _consumeItem(item),
              child: const Text(
                "EAT / DRINK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
