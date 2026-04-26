import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class AddEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const AddEditProfileScreen({super.key, this.profile});
  @override
  State<AddEditProfileScreen> createState() => _AddEditProfileScreenState();
}

class _AddEditProfileScreenState extends State<AddEditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageYearsCtrl = TextEditingController();
  final _ageMonthsCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = 'human';
  String _subtype = 'adult';

  final _humanSubtypes = ['adult', 'senior', 'child', 'pregnant'];
  final _petSubtypes = ['dog', 'cat', 'rabbit', 'bird', 'hamster', 'fish', 'reptile', 'horse'];

  static const _subtypeEmojis = {
    'adult': '👨', 'senior': '👵', 'child': '👶', 'pregnant': '🤰',
    'dog': '🐕', 'cat': '🐈', 'rabbit': '🐇', 'bird': '🐦',
    'hamster': '🐹', 'fish': '🐠', 'reptile': '🦎', 'horse': '🐴',
  };

  bool get _showMonths => ['child', 'dog', 'cat', 'rabbit', 'bird', 'hamster', 'fish', 'reptile', 'horse'].contains(_subtype);

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      final p = widget.profile!;
      _nameCtrl.text = p['name'] as String? ?? '';
      _ageYearsCtrl.text = (p['age_years'] ?? p['age'] ?? 0).toString();
      _ageMonthsCtrl.text = (p['age_months'] ?? 0).toString();
      _vetCtrl.text = p['vet_contact'] as String? ?? '';
      _notesCtrl.text = p['notes'] as String? ?? '';
      _type = p['type'] as String? ?? 'human';
      _subtype = p['subtype'] as String? ?? 'adult';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageYearsCtrl.dispose();
    _ageMonthsCtrl.dispose();
    _vetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${LocalizationHelper.t('name')} is required'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'type': _type,
        'subtype': _subtype,
        'age_years': int.tryParse(_ageYearsCtrl.text) ?? 0,
        'age_months': int.tryParse(_ageMonthsCtrl.text) ?? 0,
        'vet_contact': _vetCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      };
      if (widget.profile != null) {
        await DatabaseHelper.updateProfile(widget.profile!['id'] as int, data);
      } else {
        await DatabaseHelper.addProfile(data);
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
    final isEdit = widget.profile != null;
    final subtypes = _type == 'human' ? _humanSubtypes : _petSubtypes;
    if (!subtypes.contains(_subtype)) {
      _subtype = subtypes.first;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(
          isEdit ? LocalizationHelper.t('edit_profile') : LocalizationHelper.t('add_profile'),
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

          // Human / Pet selector
          Row(children: [
            Expanded(child: _typeCard('human', '👨', LocalizationHelper.t('human'))),
            const SizedBox(width: 12),
            Expanded(child: _typeCard('pet', '🐾', LocalizationHelper.t('pet'))),
          ]),
          const SizedBox(height: 20),

          // Subtype selector
          Text(LocalizationHelper.t('type'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subtypes.map((sub) => GestureDetector(
              onTap: () => setState(() => _subtype = sub),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _subtype == sub ? scheme.primaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _subtype == sub ? scheme.primary : scheme.outline,
                    width: _subtype == sub ? 2 : 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_subtypeEmojis[sub] ?? '👤', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(LocalizationHelper.t(sub),
                      style: TextStyle(
                        color: _subtype == sub ? scheme.primary : null,
                        fontWeight: _subtype == sub ? FontWeight.bold : FontWeight.normal,
                      )),
                ]),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Name
          _buildField(_nameCtrl, LocalizationHelper.t('name'), icon: Icons.person),
          const SizedBox(height: 12),

          // Age
          Row(children: [
            Expanded(child: _buildField(_ageYearsCtrl, LocalizationHelper.t('age_years'),
                icon: Icons.cake, isNumber: true)),
            if (_showMonths) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildField(_ageMonthsCtrl, LocalizationHelper.t('age_months'),
                  icon: Icons.date_range, isNumber: true)),
            ],
          ]),
          const SizedBox(height: 12),

          // Vet contact
          _buildField(_vetCtrl, LocalizationHelper.t('vet_contact'), icon: Icons.local_hospital),
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

  Widget _typeCard(String type, String emoji, String label) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _subtype = type == 'human' ? 'adult' : 'dog';
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _type == type ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _type == type ? scheme.primary : scheme.outline,
            width: _type == type ? 2 : 1,
          ),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _type == type ? scheme.primary : null,
          )),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label,
      {IconData? icon, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
