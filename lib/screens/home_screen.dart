import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';
import 'profiles_screen.dart';
import 'add_edit_profile_screen.dart';
import 'shopping_list_screen.dart';
import 'history_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _todayMeds = [];
  List<Map<String, dynamic>> _lowStock = [];
  bool _loading = true;
  BannerAd? _banner;
  InterstitialAd? _interstitial;
  int _interstitialCount = 0;

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

  void _loadInterstitial() {
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
    _interstitialCount++;
    if (_interstitialCount % 3 == 0 && _interstitial != null) {
      _interstitial!.show();
      _interstitial = null;
      _loadInterstitial();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    LocalizationHelper.currentLanguage =
        prefs.getString('app_language') ?? 'en';
    final profiles = await DatabaseHelper.getProfiles();
    final lowStock = await DatabaseHelper.getLowStockMedications();

    // Build today's medication list
    final List<Map<String, dynamic>> todayMeds = [];
    final now = DateTime.now();
    for (final profile in profiles) {
      final meds =
          await DatabaseHelper.getMedications(profile['id'] as int);
      for (final med in meds) {
        final times = (med['times'] as String? ?? '08:00').split(',');
        for (final time in times) {
          todayMeds.add({
            ...med,
            'profile_name': profile['name'],
            'profile_subtype': profile['subtype'],
            'scheduled_time':
                '${now.toIso8601String().substring(0, 10)} $time',
            'display_time': time,
          });
        }
      }
    }
    todayMeds.sort((a, b) =>
        a['display_time'].compareTo(b['display_time']));

    setState(() {
      _profiles = profiles;
      _todayMeds = todayMeds;
      _lowStock = lowStock;
      _loading = false;
    });
    _loadInterstitial();
  }

  String _profileEmoji(Map<String, dynamic> profile) {
    final sub = profile['subtype'] as String? ?? '';
    const map = {
      'adult': '👨',
      'senior': '👵',
      'child': '👶',
      'pregnant': '🤰',
      'dog': '🐕',
      'cat': '🐈',
      'rabbit': '🐇',
      'bird': '🐦',
      'hamster': '🐹',
      'fish': '🐠',
      'reptile': '🦎',
      'horse': '🐴',
    };
    return map[sub] ?? '👤';
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(
          LocalizationHelper.t('app_title'),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: scheme.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
              await _loadData();
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _showInterstitial();
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditProfileScreen()));
          await _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text(LocalizationHelper.t('add_profile')),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Low stock warning
                  if (_lowStock.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_lowStock.length} ${LocalizationHelper.t('low_stock')} - ${LocalizationHelper.t('refill_needed')}',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ShoppingListScreen())),
                            child: Text(LocalizationHelper.t('shopping_list')),
                          ),
                        ],
                      ),
                    ),

                  // Today's doses
                  Text(
                    LocalizationHelper.t('today'),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary),
                  ),
                  const SizedBox(height: 8),
                  if (_todayMeds.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Text(LocalizationHelper.t('all_done')),
                        ],
                      ),
                    )
                  else
                    ...(_todayMeds.map((med) => _buildDoseCard(med))),

                  const SizedBox(height: 24),

                  // Profiles
                  Row(
                    children: [
                      Text(
                        LocalizationHelper.t('profiles'),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          _showInterstitial();
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfilesScreen()));
                          await _loadData();
                        },
                        child: Text(LocalizationHelper.t('profiles')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_profiles.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text('👥',
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(LocalizationHelper.t('no_profiles'),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _profiles.length,
                      itemBuilder: (ctx, i) {
                        final profile = _profiles[i];
                        return GestureDetector(
                          onTap: () async {
                            _showInterstitial();
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfilesScreen(
                                        initialProfile: profile)));
                            await _loadData();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_profileEmoji(profile),
                                    style:
                                        const TextStyle(fontSize: 32)),
                                const SizedBox(height: 4),
                                Text(
                                  profile['name'] as String,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: scheme.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  LocalizationHelper.t(
                                      profile['subtype'] as String? ?? ''),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onPrimaryContainer),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Bottom nav
          Container(
            color: scheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navBtn(Icons.history, LocalizationHelper.t('history'),
                    () async {
                  _showInterstitial();
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryScreen()));
                }),
                _navBtn(Icons.calendar_month,
                    LocalizationHelper.t('calendar'), () async {
                  _showInterstitial();
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalendarScreen()));
                }),
                _navBtn(Icons.shopping_cart,
                    LocalizationHelper.t('shopping_list'), () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ShoppingListScreen()));
                }),
              ],
            ),
          ),
          if (_banner != null)
            SafeArea(
              top: false,
              child: SizedBox(height: 50, child: AdWidget(ad: _banner!)),
            ),
        ],
      ),
    );
  }

  Widget _buildDoseCard(Map<String, dynamic> med) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            _profileEmoji({'subtype': med['profile_subtype']}),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(med['name'] as String? ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${med['profile_name']} • ${med['display_time']} • ${med['dose']} ${med['unit']}'),
        trailing: PopupMenuButton<String>(
          onSelected: (val) async {
            await DatabaseHelper.markDose(
              med['id'] as int,
              med['profile_id'] as int,
              med['scheduled_time'] as String,
              val,
            );
            await _loadData();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'taken',
                child: Text(LocalizationHelper.t('mark_taken'))),
            PopupMenuItem(
                value: 'skipped',
                child: Text(LocalizationHelper.t('mark_skipped'))),
            PopupMenuItem(
                value: 'missed',
                child: Text(LocalizationHelper.t('missed'))),
          ],
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(LocalizationHelper.t('taken'),
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
