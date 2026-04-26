import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final int profileId;
  final String profileSubtype;
  final Map<String, dynamic>? medication;
  const AddEditMedicationScreen({
    super.key,
    required this.profileId,
    required this.profileSubtype,
    this.medication,
  });
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
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  List<String> _conflictWarnings = [];
  List<String> _toxicWarnings = [];
  bool _checkingConflicts = false;

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
      final timesStr = m['times'] as String? ?? '08:00';
      _times = timesStr.split(',').map((t) {
        final parts = t.trim().split(':');
        return TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
      }).toList();
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

  Future<void> _checkWarnings(String name) async {
    if (name.length < 3) {
      setState(() { _conflictWarnings = []; _toxicWarnings = []; });
      return;
    }
    setState(() => _checkingConflicts = true);
    try {
      final conflicts = await DatabaseHelper.checkConflicts(name, widget.profileId);
      final toxic = await DatabaseHelper.checkToxicForPet(name, widget.profileSubtype);
      setState(() {
        _conflictWarnings = conflicts.map((c) => LocalizationHelper.conflictDescription(c)).where((s) => s.isNotEmpty).toList();
        _toxicWarnings = toxic.map((t) => LocalizationHelper.toxicDescription(t)).where((s) => s.isNotEmpty).toList();
        _checkingConflicts = false;
      });
    } catch (_) {
      setState(() => _checkingConflicts = false);
    }
  }

  void _updateTimesForFrequency(String frequency) {
    setState(() {
      switch (frequency) {
        case 'twice_daily':
          _times = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)];
          break;
        case 'three_times':
          _times = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 14, minute: 0), const TimeOfDay(hour: 20, minute: 0)];
          break;
        default:
          _times = [const TimeOfDay(hour: 8, minute: 0)];
      }
      _frequency = frequency;
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(context: context, initialTime: _times[index]);
    if (picked != null) setState(() => _times[index] = picked);
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${LocalizationHelper.t('name')} is required'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final timesStr = _times.map(_formatTime).join(',');
      final data = {
        'profile_id': widget.profileId,
        'name': _nameCtrl.text.trim(),
        'dose': _doseCtrl.text.trim(),
        'unit': _unit,
        'frequency': _frequency,
        'times': timesStr,
        'stock_count': int.tryParse(_stockCtrl.text) ?? 0,
        'notes': _notesCtrl.text.trim(),
      };
      if (widget.medication != null) {
        await DatabaseHelper.updateMedication(widget.medication!['id'] as int, data);
      } else {
        await DatabaseHelper.addMedication(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.t('saved')), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.t('error')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.medication != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(
          isEdit ? LocalizationHelper.t('edit_medication') : LocalizationHelper.t('add_medication'),
          style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(LocalizationHelper.t('save'),
                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Conflict warnings
          if (_checkingConflicts)
            const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator()),

          if (_conflictWarnings.isNotEmpty)
            _warningBox(LocalizationHelper.t('conflict_warning'), _conflictWarnings, Colors.red),

          if (_toxicWarnings.isNotEmpty)
            _warningBox(LocalizationHelper.t('toxic_warning'), _toxicWarnings, Colors.orange),

          if (widget.profileSubtype == 'pregnant')
            _warningBox(LocalizationHelper.t('pregnant_warning'), [], Colors.purple),

          // Medication name
          TextField(
            controller: _nameCtrl,
            onChanged: _checkWarnings,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('name'),
              hintText: 'e.g. Metformin, Aspirin, Heartgard...',
              prefixIcon: const Icon(Icons.medication),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // Dose + Unit row
          Row(children: [
            Expanded(
              child: TextField(
                controller: _doseCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: LocalizationHelper.t('dose'),
                  prefixIcon: const Icon(Icons.scale),
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
              prefixIcon: const Icon(Icons.repeat),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(LocalizationHelper.t(f)))).toList(),
            onChanged: (v) => _updateTimesForFrequency(v!),
          ),
          const SizedBox(height: 12),

          // Schedule times
          Text(LocalizationHelper.t('schedule_times'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ..._times.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _pickTime(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.primary),
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.primaryContainer.withOpacity(0.3),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 12),
                  Text(_formatTime(entry.value),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Tap to change', style: TextStyle(fontSize: 12, color: scheme.primary)),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 12),

          // Stock
          TextField(
            controller: _stockCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${LocalizationHelper.t('stock')} (${LocalizationHelper.t('pills_left')})',
              prefixIcon: const Icon(Icons.inventory_2),
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
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(LocalizationHelper.t('save'), style: const TextStyle(fontSize: 16)),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _warningBox(String title, List<String> messages, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        if (messages.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...messages.map((m) => Text('• $m', style: TextStyle(color: color, fontSize: 13))),
        ],
      ]),
    );
  }
}
