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
  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  final String lang = prefs.getString('app_language') ?? 'en';
  LocalizationHelper.currentLanguage = lang;
  runApp(PawsAndPillsApp(showOnboarding: !seenOnboarding));
}

class PawsAndPillsApp extends StatefulWidget {
  final bool showOnboarding;
  const PawsAndPillsApp({super.key, required this.showOnboarding});
  static _PawsAndPillsAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_PawsAndPillsAppState>();
  @override
  State<PawsAndPillsApp> createState() => _PawsAndPillsAppState();
}

class _PawsAndPillsAppState extends State<PawsAndPillsApp> {
  String _language = LocalizationHelper.currentLanguage;

  void setLanguage(String lang) {
    setState(() {
      _language = lang;
      LocalizationHelper.currentLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _language == 'ar';
    return MaterialApp(
      title: 'PawsAndPills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: widget.showOnboarding
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
