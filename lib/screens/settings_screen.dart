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
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
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
    if (mounted) PawsAndPillsApp.of(context)?.setLanguage(code);
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
        title: Text(LocalizationHelper.t('settings'), style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          Text(LocalizationHelper.t('language'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 12),
          ..._languages.map((lang) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _setLanguage(lang['code']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _language == lang['code'] ? scheme.primaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _language == lang['code'] ? scheme.primary : scheme.outline),
                ),
                child: Row(children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(lang['name']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: scheme.onSurface)),
                  const Spacer(),
                  if (_language == lang['code']) Icon(Icons.check_circle, color: scheme.primary),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Notifications
          Row(children: [
            Icon(Icons.notifications, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(LocalizationHelper.t('notifications'), style: const TextStyle(fontSize: 16))),
            Switch(value: _notifications, onChanged: _toggleNotifications),
          ]),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // About
          Row(children: [
            Icon(Icons.info, color: scheme.primary),
            const SizedBox(width: 12),
            Text(LocalizationHelper.t('about'), style: const TextStyle(fontSize: 16)),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PawsAndPills', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
              Text('${LocalizationHelper.t('version')}: 1.0.0'),
              const SizedBox(height: 4),
              Text(LocalizationHelper.t('app_subtitle'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),
        ],
      ),
    );
  }
}
