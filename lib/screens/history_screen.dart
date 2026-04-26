import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _profiles = [];
  int? _selectedProfileId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profiles = await DatabaseHelper.getProfiles();
    final history = await DatabaseHelper.getDoseHistory(profileId: _selectedProfileId);
    setState(() { _profiles = profiles; _history = history; _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken': return Colors.green;
      case 'missed': return Colors.red;
      case 'skipped': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'taken': return Icons.check_circle;
      case 'missed': return Icons.cancel;
      case 'skipped': return Icons.skip_next;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('history'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: Column(children: [
        // Profile filter chips
        if (_profiles.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(children: [
              _filterChip(LocalizationHelper.t('all'), _selectedProfileId == null, () {
                setState(() => _selectedProfileId = null);
                _load();
              }),
              ..._profiles.map((p) => _filterChip(
                p['name'] as String,
                _selectedProfileId == p['id'],
                () { setState(() => _selectedProfileId = p['id'] as int); _load(); },
              )),
            ]),
          ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('📋', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text(LocalizationHelper.t('no_history'),
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _history.length,
                      itemBuilder: (ctx, i) {
                        final h = _history[i];
                        final status = h['status'] as String? ?? 'pending';
                        final medName = h['medication_name'] as String? ?? '—';
                        final profileName = h['profile_name'] as String? ?? '—';
                        final time = h['scheduled_time'] as String? ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(status).withOpacity(0.15),
                              child: Icon(_statusIcon(status), color: _statusColor(status)),
                            ),
                            title: Text(medName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$profileName  •  ${time.length > 16 ? time.substring(0, 16) : time}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(LocalizationHelper.t(status),
                                  style: TextStyle(color: _statusColor(status),
                                      fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? scheme.primary : scheme.outline,
              width: selected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? scheme.primary : null,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        )),
      ),
    );
  }
}
