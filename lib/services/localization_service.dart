import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  Map<String, dynamic>? _localizedStrings;
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  Future<void> load(String languageCode) async {
    _currentLanguage = languageCode;
    String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap;
  }
  
  String translate(String key) {
    if (_localizedStrings == null) return key;
    
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }
    
    return value?.toString() ?? key;
  }
  
  String tr(String key) => translate(key);
}

// Extension for easy access
extension LocalizationExtension on String {
  String get tr => LocalizationService.instance.translate(this);
}
