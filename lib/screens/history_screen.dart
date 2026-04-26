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
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('history'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: Column(children: [
        // Profile filter
        if (_profiles.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              GestureDetector(
                onTap: () { setState(() => _selectedProfileId = null); _load(); },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedProfileId == null ? scheme.primaryContainer : scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.primary),
                  ),
                  child: Text('All', style: TextStyle(color: scheme.primary)),
                ),
              ),
              ..._profiles.map((p) => GestureDetector(
                onTap: () { setState(() => _selectedProfileId = p['id'] as int); _load(); },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedProfileId == p['id'] ? scheme.primaryContainer : scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.primary),
                  ),
                  child: Text(p['name'] as String, style: TextStyle(color: scheme.primary)),
                ),
              )),
            ]),
          ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty
                  ? Center(child: Text(LocalizationHelper.t('no_history')))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _history.length,
                      itemBuilder: (ctx, i) {
                        final h = _history[i];
                        final status = h['status'] as String? ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(_statusIcon(status), color: _statusColor(status)),
                            title: Text(h['medication_id'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(h['scheduled_time'] as String? ?? ''),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(LocalizationHelper.t(status), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
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
