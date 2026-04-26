import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = LocalizationHelper.currentLanguage;
  bool _notifications = true;

  final _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦', 'native': 'العربية'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('app_language') ?? 'en';
      _notifications = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', code);
    LocalizationHelper.currentLanguage = code;
    setState(() => _language = code);
    if (mounted) {
      PawsAndPillsApp.of(context)?.setLanguage(code);
      setState(() {});
    }
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notifications = val);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primaryContainer,
        title: Text(LocalizationHelper.t('settings'),
            style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          _sectionHeader(LocalizationHelper.t('language'), Icons.language),
          const SizedBox(height: 10),
          ..._languages.map((lang) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _setLanguage(lang['code']!),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _language == lang['code'] ? scheme.primaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _language == lang['code'] ? scheme.primary : scheme.outline,
                    width: _language == lang['code'] ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(lang['native']!, style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _language == lang['code'] ? scheme.primary : null,
                    )),
                    Text(lang['name']!, style: TextStyle(
                      fontSize: 12,
                      color: _language == lang['code'] ? scheme.primary.withOpacity(0.7) : Colors.grey,
                    )),
                  ]),
                  const Spacer(),
                  if (_language == lang['code'])
                    Icon(Icons.check_circle, color: scheme.primary),
                ]),
              ),
            ),
          )),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Notifications section
          _sectionHeader(LocalizationHelper.t('notifications'), Icons.notifications),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline),
            ),
            child: Row(children: [
              const Icon(Icons.notifications_active),
              const SizedBox(width: 12),
              Expanded(child: Text(LocalizationHelper.t('notifications'))),
              Switch(value: _notifications, onChanged: _toggleNotifications),
            ]),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // About section
          _sectionHeader(LocalizationHelper.t('about'), Icons.info),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('💊🐾', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PawsAndPills', style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 16, color: scheme.primary)),
                  Text('${LocalizationHelper.t('version')}: 1.0.0',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ]),
              const SizedBox(height: 8),
              Text(LocalizationHelper.t('app_subtitle'),
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, color: scheme.primary, size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary)),
    ]);
  }
}
