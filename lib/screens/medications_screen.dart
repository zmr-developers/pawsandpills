import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';
import 'add_edit_medication_screen.dart';

class MedicationsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const MedicationsScreen({super.key, required this.profile});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Map<String, dynamic>> _medications = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meds = await DatabaseHelper.getMedications(widget.profile['id'] as int);
    setState(() { _medications = meds; _loading = false; });
  }

  List<Map<String, dynamic>> get _filtered => _search.isEmpty
      ? _medications
      : _medications.where((m) => (m['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocalizationHelper.t('delete_medication')),
        content: Text(LocalizationHelper.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.deleteMedication(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationHelper.t('deleted')), backgroundColor: Colors.green),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final age = DatabaseHelper.formatAge(widget.profile, LocalizationHelper.currentLanguage);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.profile['name'] as String,
              style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
          Text('${LocalizationHelper.t(widget.profile['subtype'] as String? ?? '')}${age.isNotEmpty ? ' • $age' : ''}',
              style: TextStyle(fontSize: 12, color: scheme.primary.withOpacity(0.8))),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddEditMedicationScreen(
              profileId: widget.profile['id'] as int,
              profileSubtype: widget.profile['subtype'] as String? ?? '',
            ),
          ));
          await _load();
        },
        icon: const Icon(Icons.add),
        label: Text(LocalizationHelper.t('add_medication')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: LocalizationHelper.t('search'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    isDense: true,
                  ),
                ),
              ),

              Expanded(
                child: _filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('💊', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(LocalizationHelper.t('no_medications'),
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final med = _filtered[i];
                          final stock = med['stock_count'] as int? ?? 0;
                          final isLow = stock <= 7;
                          return Dismissible(
                            key: Key('med_${med['id']}'),
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
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(LocalizationHelper.t('delete_medication')),
                                  content: Text(LocalizationHelper.t('confirm_delete')),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
                                    TextButton(onPressed: () => Navigator.pop(context, true),
                                        child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => _delete(med['id'] as int),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: isLow ? Colors.orange.shade100 : scheme.primaryContainer,
                                  child: Text(isLow ? '⚠️' : '💊', style: const TextStyle(fontSize: 20)),
                                ),
                                title: Text(med['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${med['dose']} ${med['unit']} • ${LocalizationHelper.frequencyLabel(med['frequency'] as String? ?? '')}'),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    Icon(Icons.inventory_2, size: 14, color: isLow ? Colors.orange : Colors.green),
                                    const SizedBox(width: 4),
                                    Text('$stock ${LocalizationHelper.t('pills_left')}',
                                        style: TextStyle(
                                          color: isLow ? Colors.orange : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ]),
                                ]),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      await Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => AddEditMedicationScreen(
                                          profileId: widget.profile['id'] as int,
                                          profileSubtype: widget.profile['subtype'] as String? ?? '',
                                          medication: med,
                                        ),
                                      ));
                                      await _load();
                                    } else if (val == 'delete') {
                                      await _delete(med['id'] as int);
                                    } else if (val == 'shopping') {
                                      await DatabaseHelper.addToShopping(
                                        med['name'] as String,
                                        widget.profile['name'] as String,
                                      );
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(LocalizationHelper.t('add_to_shopping')),
                                            backgroundColor: Colors.green),
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit), const SizedBox(width: 8), Text(LocalizationHelper.t('edit_medication'))])),
                                    PopupMenuItem(value: 'shopping', child: Row(children: [const Icon(Icons.shopping_cart), const SizedBox(width: 8), Text(LocalizationHelper.t('shopping_list'))])),
                                    PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 8), Text(LocalizationHelper.t('delete_medication'), style: const TextStyle(color: Colors.red))])),
                                  ],
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
}
