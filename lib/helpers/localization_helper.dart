class LocalizationHelper {
  static String currentLanguage = 'en';

  static final Map<String, Map<String, String>> _strings = {
    'app_title': {'en': 'PawsAndPills', 'ar': 'باوز آند بيلز', 'fr': 'PawsAndPills', 'es': 'PawsAndPills'},
    'app_subtitle': {'en': 'Manage medications for your entire household', 'ar': 'إدارة الأدوية لجميع أفراد منزلك', 'fr': 'Gérez les médicaments de toute votre famille', 'es': 'Gestiona medicamentos para toda tu familia'},
    'select_language': {'en': 'Select Language', 'ar': 'اختر اللغة', 'fr': 'Choisir la Langue', 'es': 'Seleccionar Idioma'},
    'get_started': {'en': 'Get Started', 'ar': 'ابدأ الآن', 'fr': 'Commencer', 'es': 'Comenzar'},
    'home': {'en': 'Home', 'ar': 'الرئيسية', 'fr': 'Accueil', 'es': 'Inicio'},
    'profiles': {'en': 'Profiles', 'ar': 'الملفات', 'fr': 'Profils', 'es': 'Perfiles'},
    'add_profile': {'en': 'Add Profile', 'ar': 'إضافة ملف', 'fr': 'Ajouter Profil', 'es': 'Agregar Perfil'},
    'edit_profile': {'en': 'Edit Profile', 'ar': 'تعديل الملف', 'fr': 'Modifier Profil', 'es': 'Editar Perfil'},
    'delete_profile': {'en': 'Delete Profile', 'ar': 'حذف الملف', 'fr': 'Supprimer Profil', 'es': 'Eliminar Perfil'},
    'medications': {'en': 'Medications', 'ar': 'الأدوية', 'fr': 'Médicaments', 'es': 'Medicamentos'},
    'add_medication': {'en': 'Add Medication', 'ar': 'إضافة دواء', 'fr': 'Ajouter Médicament', 'es': 'Agregar Medicamento'},
    'edit_medication': {'en': 'Edit Medication', 'ar': 'تعديل الدواء', 'fr': 'Modifier Médicament', 'es': 'Editar Medicamento'},
    'delete_medication': {'en': 'Delete Medication', 'ar': 'حذف الدواء', 'fr': 'Supprimer Médicament', 'es': 'Eliminar Medicamento'},
    'dose': {'en': 'Dose', 'ar': 'الجرعة', 'fr': 'Dose', 'es': 'Dosis'},
    'frequency': {'en': 'Frequency', 'ar': 'التكرار', 'fr': 'Fréquence', 'es': 'Frecuencia'},
    'once_daily': {'en': 'Once Daily', 'ar': 'مرة يومياً', 'fr': 'Une fois par jour', 'es': 'Una vez al día'},
    'twice_daily': {'en': 'Twice Daily', 'ar': 'مرتين يومياً', 'fr': 'Deux fois par jour', 'es': 'Dos veces al día'},
    'three_times': {'en': 'Three Times Daily', 'ar': 'ثلاث مرات يومياً', 'fr': 'Trois fois par jour', 'es': 'Tres veces al día'},
    'weekly': {'en': 'Weekly', 'ar': 'أسبوعياً', 'fr': 'Hebdomadaire', 'es': 'Semanal'},
    'monthly': {'en': 'Monthly', 'ar': 'شهرياً', 'fr': 'Mensuel', 'es': 'Mensual'},
    'stock': {'en': 'Stock', 'ar': 'المخزون', 'fr': 'Stock', 'es': 'Stock'},
    'low_stock': {'en': 'Low Stock', 'ar': 'مخزون منخفض', 'fr': 'Stock Faible', 'es': 'Stock Bajo'},
    'taken': {'en': 'Taken', 'ar': 'تم الأخذ', 'fr': 'Pris', 'es': 'Tomado'},
    'missed': {'en': 'Missed', 'ar': 'فائت', 'fr': 'Manqué', 'es': 'Perdido'},
    'skipped': {'en': 'Skipped', 'ar': 'تم التخطي', 'fr': 'Ignoré', 'es': 'Omitido'},
    'mark_taken': {'en': 'Mark as Taken', 'ar': 'تحديد كمأخوذ', 'fr': 'Marquer comme Pris', 'es': 'Marcar como Tomado'},
    'mark_skipped': {'en': 'Mark as Skipped', 'ar': 'تحديد كمتخطى', 'fr': 'Marquer comme Ignoré', 'es': 'Marcar como Omitido'},
    'history': {'en': 'History', 'ar': 'السجل', 'fr': 'Historique', 'es': 'Historial'},
    'calendar': {'en': 'Calendar', 'ar': 'التقويم', 'fr': 'Calendrier', 'es': 'Calendario'},
    'shopping_list': {'en': 'Shopping List', 'ar': 'قائمة التسوق', 'fr': 'Liste de Courses', 'es': 'Lista de Compras'},
    'add_to_shopping': {'en': 'Add to Shopping List', 'ar': 'أضف لقائمة التسوق', 'fr': 'Ajouter à la Liste', 'es': 'Agregar a la Lista'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'fr': 'Paramètres', 'es': 'Configuración'},
    'language': {'en': 'Language', 'ar': 'اللغة', 'fr': 'Langue', 'es': 'Idioma'},
    'notifications': {'en': 'Notifications', 'ar': 'الإشعارات', 'fr': 'Notifications', 'es': 'Notificaciones'},
    'conflict_warning': {'en': '⚠️ Drug Conflict Detected', 'ar': '⚠️ تم اكتشاف تعارض دوائي', 'fr': '⚠️ Conflit Médicamenteux Détecté', 'es': '⚠️ Conflicto de Medicamentos Detectado'},
    'toxic_warning': {'en': '⚠️ Toxic for this pet species', 'ar': '⚠️ سام لهذا النوع من الحيوانات', 'fr': '⚠️ Toxique pour cette espèce', 'es': '⚠️ Tóxico para esta especie'},
    'pregnant_warning': {'en': '⚠️ Use caution during pregnancy', 'ar': '⚠️ توخ الحذر أثناء الحمل', 'fr': '⚠️ Précaution pendant la grossesse', 'es': '⚠️ Precaución durante el embarazo'},
    'no_profiles': {'en': 'No profiles yet. Add your first profile!', 'ar': 'لا توجد ملفات بعد. أضف ملفك الأول!', 'fr': 'Pas encore de profils. Ajoutez votre premier profil!', 'es': '¡Aún no hay perfiles. Agrega tu primer perfil!'},
    'no_medications': {'en': 'No medications yet. Add a medication!', 'ar': 'لا توجد أدوية بعد. أضف دواءً!', 'fr': 'Pas encore de médicaments. Ajoutez un médicament!', 'es': '¡Aún no hay medicamentos. Agrega un medicamento!'},
    'no_history': {'en': 'No history yet', 'ar': 'لا يوجد سجل بعد', 'fr': 'Pas encore d\'historique', 'es': 'Aún no hay historial'},
    'no_shopping': {'en': 'Shopping list is empty', 'ar': 'قائمة التسوق فارغة', 'fr': 'La liste de courses est vide', 'es': 'La lista de compras está vacía'},
    'today': {'en': 'Today', 'ar': 'اليوم', 'fr': "Aujourd'hui", 'es': 'Hoy'},
    'all_done': {'en': 'All done for today!', 'ar': 'تم الانتهاء من كل شيء اليوم!', 'fr': 'Tout est fait pour aujourd\'hui!', 'es': '¡Todo listo por hoy!'},
    'human': {'en': 'Human', 'ar': 'إنسان', 'fr': 'Humain', 'es': 'Humano'},
    'pet': {'en': 'Pet', 'ar': 'حيوان أليف', 'fr': 'Animal', 'es': 'Mascota'},
    'adult': {'en': 'Adult', 'ar': 'بالغ', 'fr': 'Adulte', 'es': 'Adulto'},
    'senior': {'en': 'Senior', 'ar': 'كبير السن', 'fr': 'Sénior', 'es': 'Mayor'},
    'child': {'en': 'Child', 'ar': 'طفل', 'fr': 'Enfant', 'es': 'Niño'},
    'pregnant': {'en': 'Pregnant', 'ar': 'حامل', 'fr': 'Enceinte', 'es': 'Embarazada'},
    'dog': {'en': 'Dog', 'ar': 'كلب', 'fr': 'Chien', 'es': 'Perro'},
    'cat': {'en': 'Cat', 'ar': 'قطة', 'fr': 'Chat', 'es': 'Gato'},
    'rabbit': {'en': 'Rabbit', 'ar': 'أرنب', 'fr': 'Lapin', 'es': 'Conejo'},
    'bird': {'en': 'Bird', 'ar': 'طائر', 'fr': 'Oiseau', 'es': 'Pájaro'},
    'hamster': {'en': 'Hamster', 'ar': 'هامستر', 'fr': 'Hamster', 'es': 'Hámster'},
    'fish': {'en': 'Fish', 'ar': 'سمكة', 'fr': 'Poisson', 'es': 'Pez'},
    'reptile': {'en': 'Reptile', 'ar': 'زاحف', 'fr': 'Reptile', 'es': 'Reptil'},
    'horse': {'en': 'Horse', 'ar': 'حصان', 'fr': 'Cheval', 'es': 'Caballo'},
    'name': {'en': 'Name', 'ar': 'الاسم', 'fr': 'Nom', 'es': 'Nombre'},
    'age': {'en': 'Age', 'ar': 'العمر', 'fr': 'Âge', 'es': 'Edad'},
    'vet_contact': {'en': 'Vet / Doctor Contact', 'ar': 'معلومات الطبيب البيطري', 'fr': 'Contact Vétérinaire', 'es': 'Contacto Veterinario'},
    'notes': {'en': 'Notes', 'ar': 'ملاحظات', 'fr': 'Notes', 'es': 'Notas'},
    'save': {'en': 'Save', 'ar': 'حفظ', 'fr': 'Enregistrer', 'es': 'Guardar'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء', 'fr': 'Annuler', 'es': 'Cancelar'},
    'delete': {'en': 'Delete', 'ar': 'حذف', 'fr': 'Supprimer', 'es': 'Eliminar'},
    'confirm_delete': {'en': 'Are you sure you want to delete?', 'ar': 'هل أنت متأكد أنك تريد الحذف؟', 'fr': 'Êtes-vous sûr de vouloir supprimer?', 'es': '¿Estás seguro de que quieres eliminar?'},
    'yes': {'en': 'Yes', 'ar': 'نعم', 'fr': 'Oui', 'es': 'Sí'},
    'no': {'en': 'No', 'ar': 'لا', 'fr': 'Non', 'es': 'No'},
    'bought': {'en': 'Bought', 'ar': 'تم الشراء', 'fr': 'Acheté', 'es': 'Comprado'},
    'refill_needed': {'en': 'Refill Needed', 'ar': 'يحتاج إعادة تعبئة', 'fr': 'Recharge Nécessaire', 'es': 'Recarga Necesaria'},
    'days_left': {'en': 'days left', 'ar': 'أيام متبقية', 'fr': 'jours restants', 'es': 'días restantes'},
    'start_date': {'en': 'Start Date', 'ar': 'تاريخ البداية', 'fr': 'Date de Début', 'es': 'Fecha de Inicio'},
    'end_date': {'en': 'End Date', 'ar': 'تاريخ النهاية', 'fr': 'Date de Fin', 'es': 'Fecha de Fin'},
    'unit': {'en': 'Unit', 'ar': 'الوحدة', 'fr': 'Unité', 'es': 'Unidad'},
    'mg': {'en': 'mg', 'ar': 'ملغ', 'fr': 'mg', 'es': 'mg'},
    'ml': {'en': 'ml', 'ar': 'مل', 'fr': 'ml', 'es': 'ml'},
    'tablet': {'en': 'tablet', 'ar': 'قرص', 'fr': 'comprimé', 'es': 'comprimido'},
    'drops': {'en': 'drops', 'ar': 'قطرات', 'fr': 'gouttes', 'es': 'gotas'},
    'type': {'en': 'Type', 'ar': 'النوع', 'fr': 'Type', 'es': 'Tipo'},
    'species': {'en': 'Species', 'ar': 'الفصيلة', 'fr': 'Espèce', 'es': 'Especie'},
    'about': {'en': 'About', 'ar': 'حول', 'fr': 'À propos', 'es': 'Acerca de'},
    'version': {'en': 'Version', 'ar': 'الإصدار', 'fr': 'Version', 'es': 'Versión'},
  };

  static String t(String key) {
    return _strings[key]?[currentLanguage] ?? _strings[key]?['en'] ?? key;
  }

  static String speciesName(Map<String, dynamic> species) {
    if (currentLanguage == 'ar') return species['name_ar'] ?? species['name_en'] ?? '';
    if (currentLanguage == 'fr') return species['name_fr'] ?? species['name_en'] ?? '';
    if (currentLanguage == 'es') return species['name_es'] ?? species['name_en'] ?? '';
    return species['name_en'] ?? '';
  }

  static String conflictDescription(Map<String, dynamic> conflict) {
    if (currentLanguage == 'ar') return conflict['description_ar'] ?? conflict['description_en'] ?? '';
    if (currentLanguage == 'fr') return conflict['description_fr'] ?? conflict['description_en'] ?? '';
    if (currentLanguage == 'es') return conflict['description_es'] ?? conflict['description_en'] ?? '';
    return conflict['description_en'] ?? '';
  }

  static String toxicDescription(Map<String, dynamic> toxic) {
    if (currentLanguage == 'ar') return toxic['description_ar'] ?? toxic['description_en'] ?? '';
    if (currentLanguage == 'fr') return toxic['description_fr'] ?? toxic['description_en'] ?? '';
    if (currentLanguage == 'es') return toxic['description_es'] ?? toxic['description_en'] ?? '';
    return toxic['description_en'] ?? '';
  }

  static String frequencyLabel(String frequency) {
    return t(frequency) != frequency ? t(frequency) : frequency;
  }
}
