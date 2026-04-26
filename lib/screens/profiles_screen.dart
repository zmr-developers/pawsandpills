import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';
import 'add_edit_profile_screen.dart';
import 'medications_screen.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});
  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await DatabaseHelper.getProfiles();
    setState(() { _profiles = profiles; _loading = false; });
  }

  List<Map<String, dynamic>> get _filtered => _search.isEmpty
      ? _profiles
      : _profiles.where((p) => (p['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

  String _profileEmoji(String subtype) {
    const map = {
      'adult': '👨', 'senior': '👵', 'child': '👶', 'pregnant': '🤰',
      'dog': '🐕', 'cat': '🐈', 'rabbit': '🐇', 'bird': '🐦',
      'hamster': '🐹', 'fish': '🐠', 'reptile': '🦎', 'horse': '🐴',
    };
    return map[subtype] ?? '👤';
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocalizationHelper.t('delete_profile')),
        content: Text(LocalizationHelper.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.deleteProfile(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationHelper.t('deleted')), backgroundColor: Colors.green),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('profiles'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProfileScreen()));
          await _load();
        },
        icon: const Icon(Icons.add),
        label: Text(LocalizationHelper.t('add_profile')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
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
                        const Text('👥', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(LocalizationHelper.t('no_profiles'),
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final p = _filtered[i];
                          final age = DatabaseHelper.formatAge(p, LocalizationHelper.currentLanguage);
                          return Dismissible(
                            key: Key('profile_${p['id']}'),
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
                                  title: Text(LocalizationHelper.t('delete_profile')),
                                  content: Text(LocalizationHelper.t('confirm_delete')),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
                                    TextButton(onPressed: () => Navigator.pop(context, true),
                                        child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => _delete(p['id'] as int),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: scheme.primaryContainer,
                                  child: Text(_profileEmoji(p['subtype'] as String? ?? ''),
                                      style: const TextStyle(fontSize: 24)),
                                ),
                                title: Text(p['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${LocalizationHelper.t(p['subtype'] as String? ?? '')}${age.isNotEmpty ? ' • $age' : ''}'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      await Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => AddEditProfileScreen(profile: p),
                                      ));
                                      await _load();
                                    } else if (val == 'delete') {
                                      await _delete(p['id'] as int);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit), const SizedBox(width: 8), Text(LocalizationHelper.t('edit_profile'))])),
                                    PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red), const SizedBox(width: 8), Text(LocalizationHelper.t('delete_profile'), style: const TextStyle(color: Colors.red))])),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => MedicationsScreen(profile: p),
                                  ));
                                  await _load();
                                },
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
