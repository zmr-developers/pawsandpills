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
  final _ageCtrl = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      final p = widget.profile!;
      _nameCtrl.text = p['name'] as String? ?? '';
      _ageCtrl.text = p['age']?.toString() ?? '';
      _vetCtrl.text = p['vet_contact'] as String? ?? '';
      _notesCtrl.text = p['notes'] as String? ?? '';
      _type = p['type'] as String? ?? 'human';
      _subtype = p['subtype'] as String? ?? 'adult';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _vetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final data = {
      'name': _nameCtrl.text.trim(),
      'type': _type,
      'subtype': _subtype,
      'age': int.tryParse(_ageCtrl.text) ?? 0,
      'vet_contact': _vetCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    if (widget.profile != null) {
      await DatabaseHelper.updateProfile(widget.profile!['id'] as int, data);
    } else {
      await DatabaseHelper.addProfile(data);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEdit = widget.profile != null;
    final subtypes = _type == 'human' ? _humanSubtypes : _petSubtypes;
    if (!subtypes.contains(_subtype)) _subtype = subtypes.first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(isEdit ? LocalizationHelper.t('edit_profile') : LocalizationHelper.t('add_profile'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          TextButton(onPressed: _save, child: Text(LocalizationHelper.t('save'), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Type selector
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() { _type = 'human'; _subtype = 'adult'; }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _type == 'human' ? scheme.primaryContainer : scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _type == 'human' ? scheme.primary : scheme.outline),
                  ),
                  child: Column(children: [
                    const Text('👨', style: TextStyle(fontSize: 32)),
                    Text(LocalizationHelper.t('human'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() { _type = 'pet'; _subtype = 'dog'; }),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _type == 'pet' ? scheme.primaryContainer : scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _type == 'pet' ? scheme.primary : scheme.outline),
                  ),
                  child: Column(children: [
                    const Text('🐾', style: TextStyle(fontSize: 32)),
                    Text(LocalizationHelper.t('pet'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Subtype selector
          Text(LocalizationHelper.t('type'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subtypes.map((sub) => GestureDetector(
              onTap: () => setState(() => _subtype = sub),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _subtype == sub ? scheme.primaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _subtype == sub ? scheme.primary : scheme.outline),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_subtypeEmojis[sub] ?? '👤'),
                  const SizedBox(width: 4),
                  Text(LocalizationHelper.t(sub), style: TextStyle(color: _subtype == sub ? scheme.primary : null)),
                ]),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Name
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('name'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // Age
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('age'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),

          // Vet contact
          TextField(
            controller: _vetCtrl,
            decoration: InputDecoration(
              labelText: LocalizationHelper.t('vet_contact'),
              prefixIcon: const Icon(Icons.local_hospital),
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
