import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:usta_admin_panal/core/bindings/app_binding.dart';
import 'package:usta_admin_panal/core/constants/app_translations.dart';
import 'package:usta_admin_panal/core/routing/app_routes.dart';
import 'package:usta_admin_panal/core/services/api_client.dart';
import 'package:usta_admin_panal/core/services/api_exceptions.dart';

import 'core/constants/app_config.dart';
import 'core/services/locale_service.dart';
import 'core/services/theme_controller.dart';
import 'core/services/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  final tokenStorage = Get.put(TokenStorage());
  final initialRoute = await _resolveInitialRoute(tokenStorage);
  runApp(UstaAdminApp(initialRoute: initialRoute));
}

Future<String> _resolveInitialRoute(TokenStorage storage) async {
  final authService = AuthService();
  final refresh = storage.refreshToken;
  final access = storage.token;

  if (storage.loggedOut == true) {
    await storage.clear();
    return '/login';
  }

  bool _isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload);
      final exp = data['exp'];
      if (exp is int) {
        final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return expDate.isAfter(DateTime.now());
      }
    } catch (_) {}
    return false;
  }

  // If we have a valid access token, trust it and move fast.
  if (_isTokenValid(access) && access != null) {
    ApiClient().dio.options.headers['Authorization'] = "Bearer $access";
    return '/dashboard';
  }

  // If access token expired but refresh exists, try to refresh silently
  if (refresh != null && refresh.isNotEmpty) {
    try {
      final tokens = await authService.refresh(refresh);
      await storage.saveTokens(tokens.token, refreshToken: tokens.refreshToken);
      return '/dashboard';
      await storage.clear();
      return '/login';
    } on ApiException {
      await storage.clear();
      return '/login';
    } catch (_) {
      await storage.clear();
      return '/login';
    }
  }
  // No refresh token available or token rejected: go to login
  return '/login';
}

class UstaAdminApp extends StatelessWidget {
  final String initialRoute;
  const UstaAdminApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeService = LocaleService();
    return GetX<ThemeController>(
      init: themeController,
      builder: (controller) {
        return GetMaterialApp(
          title: 'USTA Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.themeMode.value,
          translations: AppTranslations(),
          locale: localeService.storedLocale,
          fallbackLocale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          initialBinding: AppBinding(),
          initialRoute: initialRoute,
          getPages: AppPages.pages,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data:
                  mediaQuery.copyWith(textScaleFactor: controller.textScale.value),
              child: child ?? const SizedBox.shrink(),
            );
          },
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.trackpad,
            },
          ),
        );
      },
    );
  }
}
