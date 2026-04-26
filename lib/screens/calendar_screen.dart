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
    final date = _selectedDate.toIso8601String().substring(0, 10);
    final doses = await DatabaseHelper.getDosesForDate(date);
    setState(() { _doses = doses; _loading = false; });
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _load();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken': return Colors.green;
      case 'missed': return Colors.red;
      case 'skipped': return Colors.orange;
      default: return Colors.blue;
    }
  }

  String _formatDate(DateTime d) {
    final lang = LocalizationHelper.currentLanguage;
    final months = {
      'en': ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
      'ar': ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'],
      'fr': ['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'],
      'es': ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
    };
    final m = months[lang] ?? months['en']!;
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final taken = _doses.where((d) => d['dose_status'] == 'taken').length;
    final missed = _doses.where((d) => d['dose_status'] == 'missed').length;
    final pending = _doses.where((d) => d['dose_status'] == 'pending').length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('calendar'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: Column(children: [
        // Date navigator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          color: scheme.primaryContainer,
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeDate(-1),
            ),
            Expanded(child: Column(children: [
              Text(_formatDate(_selectedDate),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
              if (_isToday)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(10)),
                  child: Text(LocalizationHelper.t('today'),
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ])),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeDate(1),
            ),
          ]),
        ),

        // Stats row
        if (_doses.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: scheme.surface,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _statChip('✅ $taken', Colors.green),
              _statChip('❌ $missed', Colors.red),
              _statChip('⏳ $pending', Colors.blue),
            ]),
          ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _doses.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('📅', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text(LocalizationHelper.t('all_done'),
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _doses.length,
                      itemBuilder: (ctx, i) {
                        final dose = _doses[i];
                        final status = dose['dose_status'] as String? ?? 'pending';
                        final statusColor = _statusColor(status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor.withOpacity(0.15),
                              child: Text(dose['display_time'] as String? ?? '',
                                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(dose['name'] as String? ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${dose['profile_name']}  •  ${dose['dose']} ${dose['unit']}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (val) async {
                                await DatabaseHelper.markDose(
                                  dose['id'] as int,
                                  dose['profile_id'] as int,
                                  dose['name'] as String,
                                  dose['profile_name'] as String,
                                  dose['scheduled_time'] as String,
                                  val,
                                );
                                await _load();
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(value: 'taken', child: Text(LocalizationHelper.t('mark_taken'))),
                                PopupMenuItem(value: 'skipped', child: Text(LocalizationHelper.t('mark_skipped'))),
                                PopupMenuItem(value: 'missed', child: Text(LocalizationHelper.t('mark_missed'))),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(LocalizationHelper.t(status),
                                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ]),
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
