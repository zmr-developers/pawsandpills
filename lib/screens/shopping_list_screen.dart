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
    final pending = _items.where((i) => i['bought'] == 0).length;
    final bought = _items.where((i) => i['bought'] == 1).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('shopping_list'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          if (bought > 0)
            TextButton(
              onPressed: () async {
                for (final item in _items.where((i) => i['bought'] == 1)) {
                  await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                }
                await _load();
              },
              child: Text('Clear Done', style: TextStyle(color: scheme.primary)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🛒', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(LocalizationHelper.t('no_shopping'),
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                ]))
              : Column(children: [
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _statChip('🛒 $pending pending', Colors.orange),
                      _statChip('✅ $bought bought', Colors.green),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) {
                        final item = _items[i];
                        final isBought = item['bought'] == 1;
                        return Dismissible(
                          key: Key('shop_${item['id']}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                            await _load();
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: isBought,
                                activeColor: scheme.primary,
                                onChanged: (_) async {
                                  await DatabaseHelper.toggleShoppingBought(
                                      item['id'] as int, item['bought'] as int);
                                  await _load();
                                },
                              ),
                              title: Text(item['medication_name'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: isBought ? TextDecoration.lineThrough : null,
                                    color: isBought ? Colors.grey : null,
                                  )),
                              subtitle: Text(item['profile_name'] as String,
                                  style: TextStyle(color: isBought ? Colors.grey : null)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await DatabaseHelper.deleteShoppingItem(item['id'] as int);
                                  await _load();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]),
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
