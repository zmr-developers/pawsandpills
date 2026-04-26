import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final int profileId;
  final String profileSubtype;
  final Map<String, dynamic>? medication;
  const AddEditMedicationScreen({super.key, required this.profileId, required this.profileSubtype, this.medication});
  @override
  State<AddEditMedicationScreen> createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'mg';
  String _frequency = 'once_daily';
  List<String> _conflictWarnings = [];
  List<String> _toxicWarnings = [];

  final _units = ['mg', 'ml', 'tablet', 'drops'];
  final _frequencies = ['once_daily', 'twice_daily', 'three_times', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      final m = widget.medication!;
      _nameCtrl.text = m['name'] as String? ?? '';
      _doseCtrl.text = m['dose'] as String? ?? '';
      _stockCtrl.text = m['stock_count']?.toString() ?? '';
      _notesCtrl.text = m['notes'] as String? ?? '';
      _unit = m['unit'] as String? ?? 'mg';
      _frequency = m['frequency'] as String? ?? 'once_daily';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _stockCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkConflictsAndToxic(String name) async {
    if (name.length < 3) return;
    final conflicts = await DatabaseHelper.checkConflicts(name, widget.profileId);
    final toxic = await DatabaseHelper.checkToxicForPet(name, widget.profileSubtype);
    setState(() {
      _conflictWarnings = conflicts.map((c) => LocalizationHelper.conflictDescription(c)).toList();
      _toxicWarnings = toxic.map((t) => LocalizationHelper.toxicDescription(t)).toList();
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final data = {
      'profile_id': widget.profileId,
      'name': _nameCtrl.text.trim(),
      'dose': _doseCtrl.text.trim(),
      'unit': _unit,
      'frequency': _frequency,
      'times': _frequency == 'twice_daily' ? '08:00,20:00' : '08:00',
      'stock_count': int.tryParse(_stockCtrl.text) ?? 0,
      'notes': _notesCtrl.text.trim(),
    };
    if (widget.medication != null) {
      await DatabaseHelper.updateMedication(widget.medication!['id'] as int, data);
    } else {
      await DatabaseHelper.addMedication(data);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.medication != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(isEdit ? LocalizationHelper.t('edit_medication') : LocalizationHelper.t('add_medication'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          TextButton(onPressed: _save, child: Text(LocalizationHelper.t('save'), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Conflict warnings
          if (_conflictWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(LocalizationHelper.t('conflict_warning'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ..._conflictWarnings.map((w) => Text('• $w', style: const TextStyle(color: Colors.red, fontSize: 13))),
              ]),
            ),

          // Toxic warnings
          if (_toxicWarnings.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(LocalizationHelper.t('toxic_warning'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ..._toxicWarnings.map((w) => Text('• $w', style: const TextStyle(color: Colors.orange, fontSize: 13))),
              ]),
            ),

          // Medication name
          TextField(
            controller: _nameCtrl,
            onChanged: _checkConflictsAndToxic,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('name'),
              hintText: 'e.g. Metformin, Aspirin...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // Dose + Unit
          Row(children: [
            Expanded(
              child: TextField(
                controller: _doseCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.t('dose'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _unit,
                decoration: InputDecoration(
                  labelText: LocalizationHelper.t('unit'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(LocalizationHelper.t(u)))).toList(),
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Frequency
          DropdownButtonFormField<String>(
            value: _frequency,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('frequency'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(LocalizationHelper.t(f)))).toList(),
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          const SizedBox(height: 12),

          // Stock
          TextField(
            controller: _stockCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${LocalizationHelper.t('stock')} (${LocalizationHelper.t('days_left')})',
              prefixIcon: const Icon(Icons.inventory),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // Notes
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('notes'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(LocalizationHelper.t('save'), style: const TextStyle(fontSize: 16)),
            ),
          ),
        ]),
      ),
    );
  }
}
