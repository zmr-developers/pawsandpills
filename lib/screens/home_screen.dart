import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/localization_helper.dart';
import '../db/database_helper.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  List<Map<String, dynamic>> _profiles = [];
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _loadBannerAd();
  }

  Future<void> _loadProfiles() async {
    final db = await DatabaseHelper.database;
    final profiles = await db.query('profiles', orderBy: 'created_at DESC');
    setState(() => _profiles = profiles);
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _adLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _addProfile() async {
    final scheme = Theme.of(context).colorScheme;
    String name = '';
    String type = 'human';
    String subtype = 'adult';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationHelper.t('add_profile')),
        content: StatefulBuilder(builder: (ctx, setS) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Name'), onChanged: (v) => name = v),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              items: ['human', 'pet'].map((t) => DropdownMenuItem(value: t, child: Text(LocalizationHelper.t(t)))).toList(),
              onChanged: (v) => setS(() { type = v!; subtype = type == 'human' ? 'adult' : 'dog'; }),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: subtype,
              items: (type == 'human' ? ['adult', 'senior', 'elderly', 'child', 'baby', 'pregnant'] : ['dog', 'cat', 'rabbit', 'bird', 'hamster', 'fish', 'reptile', 'horse']).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setS(() => subtype = v!),
              decoration: const InputDecoration(labelText: 'Subtype'),
            ),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (name.trim().isEmpty) return;
              final db = await DatabaseHelper.database;
              await db.insert('profiles', {'name': name.trim(), 'type': type, 'subtype': subtype, 'created_at': DateTime.now().toIso8601String()});
              Navigator.pop(ctx);
              _loadProfiles();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _emojiForProfile(Map<String, dynamic> p) {
    final sub = p['subtype'] as String? ?? '';
    const map = {'adult': '👤', 'senior': '👴', 'elderly': '👵', 'child': '👦', 'baby': '👶', 'pregnant': '🤰', 'dog': '🐕', 'cat': '🐈', 'rabbit': '🐇', 'bird': '🦜', 'hamster': '����', 'fish': '🐠', 'reptile': '🦎', 'horse': '🐴'};
    return map[sub] ?? '👤';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(LocalizationHelper.t('app_name'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {}))),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _profiles.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🐾', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(LocalizationHelper.t('no_profiles'), style: TextStyle(fontSize: 16, color: scheme.onSurface)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _profiles.length,
                    itemBuilder: (ctx, i) {
                      final p = _profiles[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: scheme.primaryContainer, child: Text(_emojiForProfile(p), style: const TextStyle(fontSize: 22))),
                          title: Text(p['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${p['type']} • ${p['subtype']}'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ),
          if (_adLoaded && _bannerAd != null)
            SafeArea(
              top: false,
              child: SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProfile,
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(LocalizationHelper.t('add_profile')),
      ),
    );
  }
}
