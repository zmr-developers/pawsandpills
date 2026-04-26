import 'package:shared_preferences/shared_preferences.dart';

class LocalizationHelper {
  static String _lang = 'en';
  static String get currentLanguage => _lang;

  static void setLanguage(String lang) {
    _lang = lang;
    SharedPreferences.getInstance().then((p) => p.setString('app_language', lang));
  }

  static bool get isRtl => _lang == 'ar';

  static const Map<String, Map<String, String>> _strings = {
    'app_name': {'en': 'PawsAndPills', 'ar': 'مخالب وحبوب', 'fr': 'PattesEtPilules', 'es': 'PatasYPastillas'},
    'home': {'en': 'Home', 'ar': 'الرئيسية', 'fr': 'Accueil', 'es': 'Inicio'},
    'profiles': {'en': 'Profiles', 'ar': 'الملفات', 'fr': 'Profils', 'es': 'Perfiles'},
    'medications': {'en': 'Medications', 'ar': 'الأدوية', 'fr': 'Médicaments', 'es': 'Medicamentos'},
    'calendar': {'en': 'Calendar', 'ar': 'التقويم', 'fr': 'Calendrier', 'es': 'Calendario'},
    'history': {'en': 'History', 'ar': 'السجل', 'fr': 'Historique', 'es': 'Historial'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'fr': 'Paramètres', 'es': 'Ajustes'},
    'add_profile': {'en': 'Add Profile', 'ar': 'إضافة ملف', 'fr': 'Ajouter Profil', 'es': 'Agregar Perfil'},
    'shopping_list': {'en': 'Shopping List', 'ar': 'قائمة التسوق', 'fr': 'Liste de courses', 'es': 'Lista de compras'},
    'conflicts': {'en': 'Conflict Checker', 'ar': 'فحص التعارضات', 'fr': 'Vérificateur', 'es': 'Verificador'},
    'today_doses': {'en': "Today's Doses", 'ar': 'جرعات اليوم', 'fr': "Doses d'aujourd'hui", 'es': 'Dosis de hoy'},
    'no_profiles': {'en': 'No profiles yet. Add one!', 'ar': 'لا ملفات بعد. أضف واحدًا!', 'fr': 'Aucun profil. Ajoutez-en un!', 'es': 'Sin perfiles. ¡Agrega uno!'},
    'language': {'en': 'Language', 'ar': 'اللغة', 'fr': 'Langue', 'es': 'Idioma'},
    'select_language': {'en': 'Select Language', 'ar': 'اختر اللغة', 'fr': 'Choisir la langue', 'es': 'Seleccionar idioma'},
    'get_started': {'en': 'Get Started', 'ar': 'ابدأ', 'fr': 'Commencer', 'es': 'Empezar'},
    'welcome': {'en': 'Welcome to PawsAndPills', 'ar': 'مرحبًا بك في مخالب وحبوب', 'fr': 'Bienvenue sur PawsAndPills', 'es': 'Bienvenido a PawsAndPills'},
    'welcome_sub': {'en': 'Manage medications for your entire household', 'ar': 'أدِر أدوية منزلك بالكامل', 'fr': 'Gérez les médicaments de toute votre famille', 'es': 'Gestiona medicamentos de todo tu hogar'},
    'human': {'en': 'Human', 'ar': 'إنسان', 'fr': 'Humain', 'es': 'Humano'},
    'pet': {'en': 'Pet', 'ar': 'حيوان أليف', 'fr': 'Animal', 'es': 'Mascota'},
    'taken': {'en': 'Taken', 'ar': 'تم أخذه', 'fr': 'Pris', 'es': 'Tomado'},
    'missed': {'en': 'Missed', 'ar': 'فاته', 'fr': 'Manqué', 'es': 'Perdido'},
    'upcoming': {'en': 'Upcoming', 'ar': 'قادم', 'fr': 'À venir', 'es': 'Próximo'},
    'notifications': {'en': 'Notifications', 'ar': 'الإشعارات', 'fr': 'Notifications', 'es': 'Notificaciones'},
    'about': {'en': 'About', 'ar': 'حول', 'fr': 'À propos', 'es': 'Acerca de'},
  };

  static String t(String key) {
    return _strings[key]?[_lang] ?? _strings[key]?['en'] ?? key;
  }
}
