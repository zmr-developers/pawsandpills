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

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final meds = await DatabaseHelper.getMedications(widget.profile['id'] as int);
    setState(() { _medications = meds; _loading = false; });
  }

  Future<void> _deleteMedication(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocalizationHelper.t('delete_medication')),
        content: Text(LocalizationHelper.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.deleteMedication(id);
      await _loadMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.profile['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
          Text(LocalizationHelper.t(widget.profile['subtype'] as String? ?? ''), style: TextStyle(fontSize: 12, color: scheme.primary)),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddEditMedicationScreen(profileId: widget.profile['id'] as int, profileSubtype: widget.profile['subtype'] as String? ?? ''),
          ));
          await _loadMedications();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('💊', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(LocalizationHelper.t('no_medications'), textAlign: TextAlign.center),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medications.length,
                  itemBuilder: (ctx, i) {
                    final med = _medications[i];
                    final stock = med['stock_count'] as int? ?? 0;
                    final isLow = stock <= 7;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLow ? Colors.orange.shade100 : scheme.primaryContainer,
                          child: Text(isLow ? '⚠️' : '💊', style: const TextStyle(fontSize: 20)),
                        ),
                        title: Text(med['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${med['dose']} ${med['unit']} • ${LocalizationHelper.frequencyLabel(med['frequency'] as String? ?? '')}'),
                          Text('${LocalizationHelper.t('stock')}: $stock ${LocalizationHelper.t('days_left')}',
                              style: TextStyle(color: isLow ? Colors.orange : Colors.green, fontSize: 12)),
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
                              await _loadMedications();
                            } else if (val == 'delete') {
                              await _deleteMedication(med['id'] as int);
                            } else if (val == 'shopping') {
                              await DatabaseHelper.addToShopping(med['name'] as String, widget.profile['name'] as String);
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LocalizationHelper.t('add_to_shopping'))));
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(LocalizationHelper.t('edit_medication'))),
                            PopupMenuItem(value: 'shopping', child: Text(LocalizationHelper.t('add_to_shopping'))),
                            PopupMenuItem(value: 'delete', child: Text(LocalizationHelper.t('delete_medication'), style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
