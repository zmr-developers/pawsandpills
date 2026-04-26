import 'package:flutter/material.dart';
import '../helpers/localization_helper.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = LocalizationHelper.currentLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  void _changeLanguage(String lang) {
    PawsAndPillsApp.of(context)?.setLanguage(lang);
    setState(() => _currentLang = lang);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(LocalizationHelper.t('settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocalizationHelper.t('language'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
                  const SizedBox(height: 12),
                  ..._languages.map((lang) => InkWell(
                    onTap: () => _changeLanguage(lang['code']!),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _currentLang == lang['code'] ? scheme.primaryContainer : scheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _currentLang == lang['code'] ? scheme.primary : scheme.outline),
                      ),
                      child: Row(
                        children: [
                          Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Text(lang['name']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: scheme.onSurface)),
                          const Spacer(),
                          if (_currentLang == lang['code']) Icon(Icons.check_circle, color: scheme.primary),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.notifications, color: scheme.primary),
              title: Text(LocalizationHelper.t('notifications')),
              trailing: Switch(value: true, onChanged: (_) {}, activeColor: scheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: scheme.primary),
              title: Text(LocalizationHelper.t('about')),
              subtitle: const Text('PawsAndPills v1.0.0'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
