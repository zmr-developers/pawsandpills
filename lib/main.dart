import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/database_helper.dart';
import 'helpers/localization_helper.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await DatabaseHelper.database;
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('app_language') ?? '';
  final firstLaunch = lang.isEmpty;
  LocalizationHelper.setLanguage(lang.isEmpty ? 'en' : lang);
  runApp(PawsAndPillsApp(firstLaunch: firstLaunch));
}

class PawsAndPillsApp extends StatefulWidget {
  final bool firstLaunch;
  const PawsAndPillsApp({super.key, required this.firstLaunch});
  static _PawsAndPillsAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_PawsAndPillsAppState>();
  @override
  State<PawsAndPillsApp> createState() => _PawsAndPillsAppState();
}

class _PawsAndPillsAppState extends State<PawsAndPillsApp> {
  String _lang = LocalizationHelper.currentLanguage;
  void setLanguage(String lang) {
    LocalizationHelper.setLanguage(lang);
    setState(() => _lang = lang);
  }
  @override
  Widget build(BuildContext context) {
    final isRtl = _lang == 'ar';
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        title: 'PawsAndPills',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        home: widget.firstLaunch ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
