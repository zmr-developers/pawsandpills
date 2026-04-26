import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';
import 'add_edit_profile_screen.dart';
import 'medications_screen.dart';

class ProfilesScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;
  const ProfilesScreen({super.key, this.initialProfile});
  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    if (widget.initialProfile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openProfile(widget.initialProfile!);
      });
    }
  }

  Future<void> _loadProfiles() async {
    final profiles = await DatabaseHelper.getProfiles();
    setState(() { _profiles = profiles; _loading = false; });
  }

  String _profileEmoji(Map<String, dynamic> profile) {
    const map = {
      'adult': '👨', 'senior': '👵', 'child': '👶', 'pregnant': '🤰',
      'dog': '🐕', 'cat': '🐈', 'rabbit': '🐇', 'bird': '🐦',
      'hamster': '🐹', 'fish': '🐠', 'reptile': '🦎', 'horse': '🐴',
    };
    return map[profile['subtype'] as String? ?? ''] ?? '👤';
  }

  void _openProfile(Map<String, dynamic> profile) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MedicationsScreen(profile: profile),
    )).then((_) => _loadProfiles());
  }

  Future<void> _deleteProfile(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocalizationHelper.t('delete_profile')),
        content: Text(LocalizationHelper.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(LocalizationHelper.t('no'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(LocalizationHelper.t('yes'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.deleteProfile(id);
      await _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('profiles'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProfileScreen()));
          await _loadProfiles();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? Center(child: Text(LocalizationHelper.t('no_profiles'), textAlign: TextAlign.center))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _profiles.length,
                  itemBuilder: (ctx, i) {
                    final p = _profiles[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          child: Text(_profileEmoji(p), style: const TextStyle(fontSize: 24)),
                        ),
                        title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(LocalizationHelper.t(p['subtype'] as String? ?? '')),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val == 'edit') {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProfileScreen(profile: p)));
                              await _loadProfiles();
                            } else if (val == 'delete') {
                              await _deleteProfile(p['id'] as int);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(LocalizationHelper.t('edit_profile'))),
                            PopupMenuItem(value: 'delete', child: Text(LocalizationHelper.t('delete_profile'), style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                        onTap: () => _openProfile(p),
                      ),
                    );
                  },
                ),
    );
  }
}
