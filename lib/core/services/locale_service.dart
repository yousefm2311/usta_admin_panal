import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleService {
  static const _key = 'app_locale';
  final GetStorage _box = GetStorage();

  Locale get storedLocale {
    final code = _box.read<String>(_key);
    if (code == 'ar') return const Locale('ar');
    return const Locale('en');
  }

  Future<void> save(Locale locale) async {
    await _box.write(_key, locale.languageCode);
    Get.updateLocale(locale);
  }
}
