import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _doses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final doses = await DatabaseHelper.getTodayDoses();
    setState(() { _doses = doses; _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken': return Colors.green;
      case 'missed': return Colors.red;
      case 'skipped': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('calendar'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: Column(children: [
        // Date navigator
        Container(
          padding: const EdgeInsets.all(16),
          color: scheme.primaryContainer,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () { setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))); _load(); },
            ),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () { setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))); _load(); },
            ),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _doses.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('✅', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(LocalizationHelper.t('all_done')),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _doses.length,
                      itemBuilder: (ctx, i) {
                        final dose = _doses[i];
                        final status = dose['status'] as String? ?? 'pending';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(status).withOpacity(0.2),
                              child: Text(dose['scheduled_time'].toString().substring(11, 16), style: TextStyle(fontSize: 11, color: _statusColor(status), fontWeight: FontWeight.bold)),
                            ),
                            title: Text(dose['med_name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(dose['profile_name'] as String? ?? ''),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(LocalizationHelper.t(status), style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
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
