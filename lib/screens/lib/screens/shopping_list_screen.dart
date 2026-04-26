import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseHelper.getShoppingList();
    setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('shopping_list'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🛒', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(LocalizationHelper.t('no_shopping')),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) {
                    final item = _items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: item['bought'] == 1,
                          onChanged: (_) async {
                            await DatabaseHelper.toggleShoppingBought(item['id'] as int, item['bought'] as int);
                            await _load();
                          },
                        ),
                        title: Text(item['medication_name'] as String,
                            style: TextStyle(decoration: item['bought'] == 1 ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
                        subtitle: Text(item['profile_name'] as String),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                            await _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
