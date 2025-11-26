import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:usta_admin_panal/core/bindings/app_binding.dart';
import 'package:usta_admin_panal/core/constants/app_translations.dart';
import 'package:usta_admin_panal/core/routing/app_routes.dart';

import 'core/services/token_storage.dart';
import 'core/services/locale_service.dart';
import 'core/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final tokenStorage = Get.put(TokenStorage());
  final localeService = LocaleService();
  runApp(const UstaAdminApp());
}

class UstaAdminApp extends StatelessWidget {
  const UstaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = Get.find<TokenStorage>();
    final localeService = LocaleService();
    final initialRoute = (tokenStorage.token ?? '').isNotEmpty ? '/dashboard' : '/login';
    return GetMaterialApp(
      title: 'USTA Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      translations: AppTranslations(),
      locale: localeService.storedLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialBinding: AppBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
