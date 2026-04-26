import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';
import 'medications_screen.dart';
import 'add_edit_profile_screen.dart';
import 'shopping_list_screen.dart';
import 'history_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'profiles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _todayDoses = [];
  List<Map<String, dynamic>> _lowStock = [];
  bool _loading = true;
  BannerAd? _banner;
  InterstitialAd? _interstitial;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadData();
  }

  void _loadBanner() {
    _banner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _showInterstitial() {
    DatabaseHelper.incrementInterstitial();
    if (DatabaseHelper.shouldShowInterstitial() && _interstitial != null) {
      _interstitial!.show();
      _interstitial = null;
      _loadInterstitialAd();
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      LocalizationHelper.currentLanguage = prefs.getString('app_language') ?? 'en';
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final profiles = await DatabaseHelper.getProfiles();
      final todayDoses = await DatabaseHelper.getDosesForDate(today);
      final lowStock = await DatabaseHelper.getLowStockMedications();
      setState(() {
        _profiles = profiles;
        _todayDoses = todayDoses;
        _lowStock = lowStock;
        _loading = false;
      });
      _loadInterstitialAd();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.t('error')), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _profileEmoji(String subtype) {
    const map = {
      'adult': '👨', 'senior': '👵', 'child': '👶', 'pregnant': '🤰',
      'dog': '🐕', 'cat': '🐈', 'rabbit': '🐇', 'bird': '🐦',
      'hamster': '🐹', 'fish': '🐠', 'reptile': '🦎', 'horse': '🐴',
    };
    return map[subtype] ?? '👤';
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
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('app_title'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              await _loadData();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _showInterstitial();
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProfileScreen()));
          await _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text(LocalizationHelper.t('add_profile')),
      ),
      body: Column(children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Low stock warning banner
                if (_lowStock.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        '${_lowStock.length} ${LocalizationHelper.t('low_stock')}',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      )),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingListScreen())),
                        child: Text(LocalizationHelper.t('shopping_list')),
                      ),
                    ]),
                  ),

                // Today's schedule
                Text(LocalizationHelper.t('today'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
                const SizedBox(height: 8),

                if (_todayDoses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(LocalizationHelper.t('all_done'),
                        style: const TextStyle(fontSize: 16, color: Colors.green))),
                  )
                else
                  ..._todayDoses.map((dose) {
                    final status = dose['dose_status'] as String? ?? 'pending';
                    final statusColor = _statusColor(status);
                    return Dismissible(
                      key: Key('${dose['id']}_${dose['scheduled_time']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.green,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await DatabaseHelper.markDose(
                          dose['id'] as int,
                          dose['profile_id'] as int,
                          dose['name'] as String,
                          dose['profile_name'] as String,
                          dose['scheduled_time'] as String,
                          'taken',
                        );
                        await _loadData();
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Text(dose['display_time'] as String? ?? '',
                                style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(dose['name'] as String? ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${_profileEmoji(dose['profile_subtype'] as String? ?? '')} ${dose['profile_name']}  •  ${dose['dose']} ${dose['unit']}'),
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
                              await _loadData();
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'taken', child: Row(children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text(LocalizationHelper.t('mark_taken'))])),
                              PopupMenuItem(value: 'skipped', child: Row(children: [const Icon(Icons.skip_next, color: Colors.orange), const SizedBox(width: 8), Text(LocalizationHelper.t('mark_skipped'))])),
                              PopupMenuItem(value: 'missed', child: Row(children: [const Icon(Icons.cancel, color: Colors.red), const SizedBox(width: 8), Text(LocalizationHelper.t('mark_missed'))])),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(LocalizationHelper.t(status),
                                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Profiles section
                Row(children: [
                  Text(LocalizationHelper.t('profiles'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilesScreen()));
                      await _loadData();
                    },
                    child: const Text('View All'),
                  ),
                ]),
                const SizedBox(height: 8),

                if (_profiles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(children: [
                      const Text('👥', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(LocalizationHelper.t('no_profiles'), textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14)),
                    ]),
                  )
                else
                  ..._profiles.map((profile) {
                    final age = DatabaseHelper.formatAge(profile, LocalizationHelper.currentLanguage);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          child: Text(_profileEmoji(profile['subtype'] as String? ?? ''),
                              style: const TextStyle(fontSize: 22)),
                        ),
                        title: Text(profile['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${LocalizationHelper.t(profile['subtype'] as String? ?? '')}${age.isNotEmpty ? ' • $age' : ''}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          _showInterstitial();
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => MedicationsScreen(profile: profile),
                          ));
                          await _loadData();
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),

        // Bottom navigation
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBtn(Icons.history, LocalizationHelper.t('history'), () async {
                _showInterstitial();
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                await _loadData();
              }),
              _navBtn(Icons.calendar_month, LocalizationHelper.t('calendar'), () async {
                _showInterstitial();
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
              }),
              _navBtn(Icons.shopping_cart, LocalizationHelper.t('shopping_list'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingListScreen()));
              }),
            ],
          ),
        ),

        if (_banner != null)
          SafeArea(
            top: false,
            child: SizedBox(height: 50, child: AdWidget(ad: _banner!)),
          ),
      ]),
    );
  }

  Widget _navBtn(IconData icon, String label, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: scheme.primary)),
        ]),
      ),
    );
  }
}
