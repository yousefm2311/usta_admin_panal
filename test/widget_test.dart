import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:usta_admin_panal/core/services/theme_controller.dart';
import 'package:usta_admin_panal/main.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (call) async {
        return Directory.systemTemp.path;
      },
    );
    await GetStorage.init();
    Get.reset();
    Get.put(ThemeController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      null,
    );
  });

  testWidgets('login screen renders the admin auth form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UstaAdminApp(initialRoute: '/login'));
    await tester.pumpAndSettle();

    expect(find.text('USTA Platform'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
