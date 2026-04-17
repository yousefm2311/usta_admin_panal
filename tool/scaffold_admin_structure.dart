import 'dart:io';

/// Run with:
/// dart run tool/scaffold_admin_structure.dart
void main() async {
  final paths = <String>[
    // root
    'lib/main.dart',

    // core
    'lib/core/theme/app_theme.dart',
    'lib/core/constants/app_colors.dart',
    'lib/core/constants/app_strings.dart',
    'lib/core/constants/app_sizes.dart',
    'lib/core/routing/app_routes.dart',
    'lib/core/services/api_client.dart',
    'lib/core/services/storage_service.dart',

    // data
    'lib/data/models/admin_user_model.dart',
    'lib/data/models/customer_model.dart',
    'lib/data/models/artisan_model.dart',
    'lib/data/models/request_model.dart',
    'lib/data/models/payment_model.dart',
    'lib/data/models/withdrawal_model.dart',
    'lib/data/models/review_model.dart',
    'lib/data/models/category_model.dart',
    'lib/data/models/analytics_model.dart',
    'lib/data/models/notification_model.dart',
    'lib/data/providers/admin_api_service.dart',

    // layout
    'lib/layout/admin_layout.dart',
    'lib/layout/widgets/sidebar.dart',
    'lib/layout/widgets/top_bar.dart',

    // widgets (shared)
    'lib/widgets/primary_button.dart',
    'lib/widgets/table_wrapper.dart',
    'lib/widgets/empty_state.dart',
    'lib/widgets/loading_overlay.dart',

    // modules - auth
    'lib/modules/auth/controllers/auth_controller.dart',
    'lib/modules/auth/views/login_view.dart',

    // modules - dashboard
    'lib/modules/dashboard/controllers/dashboard_controller.dart',
    'lib/modules/dashboard/views/dashboard_view.dart',

    // modules - customers
    'lib/modules/customers/controllers/customers_controller.dart',
    'lib/modules/customers/views/customers_list_view.dart',
    'lib/modules/customers/views/customer_details_view.dart',

    // modules - artisans
    'lib/modules/artisans/controllers/artisans_controller.dart',
    'lib/modules/artisans/views/artisans_list_view.dart',
    'lib/modules/artisans/views/artisan_details_view.dart',

    // modules - categories
    'lib/modules/categories/controllers/categories_controller.dart',
    'lib/modules/categories/views/categories_list_view.dart',
    'lib/modules/categories/views/category_form_view.dart',

    // modules - requests
    'lib/modules/requests/controllers/requests_controller.dart',
    'lib/modules/requests/views/requests_list_view.dart',
    'lib/modules/requests/views/request_details_view.dart',

    // modules - payments
    'lib/modules/payments/controllers/payments_controller.dart',
    'lib/modules/payments/views/payments_list_view.dart',

    // modules - withdrawals
    'lib/modules/withdrawals/controllers/withdrawals_controller.dart',
    'lib/modules/withdrawals/views/withdrawals_list_view.dart',

    // modules - reviews
    'lib/modules/reviews/controllers/reviews_controller.dart',
    'lib/modules/reviews/views/reviews_list_view.dart',

    // modules - analytics
    'lib/modules/analytics/controllers/analytics_controller.dart',
    'lib/modules/analytics/views/analytics_overview_view.dart',

    // modules - notifications
    'lib/modules/notifications/controllers/notifications_controller.dart',
    'lib/modules/notifications/views/notifications_center_view.dart',
    'lib/modules/notifications/views/send_notification_view.dart',

    // modules - settings
    'lib/modules/settings/controllers/settings_controller.dart',
    'lib/modules/settings/views/settings_general_view.dart',
    'lib/modules/settings/views/settings_commission_view.dart',

    // modules - ai
    'lib/modules/ai/controllers/ai_controller.dart',
    'lib/modules/ai/views/ai_reviews_insights_view.dart',
    'lib/modules/ai/views/ai_top_artisans_view.dart',
  ];

  for (final path in paths) {
    await _createFileWithBoilerplate(path);
  }

  stdout.writeln('✅ Admin panel structure created successfully.');
}

Future<void> _createFileWithBoilerplate(String filePath) async {
  final file = File(filePath);
  final dir = file.parent;

  if (!await dir.exists()) {
    await dir.create(recursive: true);
    stdout.writeln('📁 Created directory: ${dir.path}');
  }

  if (!await file.exists()) {
    await file.writeAsString(_boilerplateFor(filePath));
    stdout.writeln('📄 Created file: ${file.path}');
  } else {
    stdout.writeln('⚠️ File already exists, skipped: ${file.path}');
  }
}

String _boilerplateFor(String path) {
  final isMain = path == 'lib/main.dart';

  if (isMain) {
    return '''
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'layout/admin_layout.dart';

void main() {
  runApp(const UstaAdminApp());
}

class UstaAdminApp extends StatelessWidget {
  const UstaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USTA Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AdminLayout(),
    );
  }
}
''';
  }

  if (path.startsWith('lib/layout/admin_layout')) {
    return '''
import 'package:flutter/material.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_bar.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                TopBar(),
                Expanded(child: DashboardView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
''';
  }

  if (path.startsWith('lib/layout/widgets/sidebar')) {
    return '''
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF0B1020),
      child: const Center(
        child: Text(
          'USTA Admin',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
''';
  }

  if (path.startsWith('lib/layout/widgets/top_bar')) {
    return '''
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF050816),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Text(
          'لوحة التحكم',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
''';
  }

  if (path.startsWith('lib/modules/dashboard/views/dashboard_view')) {
    return '''
import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050816),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Dashboard Placeholder',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
''';
  }

  if (path.endsWith('_controller.dart')) {
    final className = _pathToClassName(
      path.split('/').last.replaceAll('.dart', ''),
    );
    return '''
import 'package:get/get.dart';

class $className extends GetxController {
  // TODO: implement controller logic
}
''';
  }

  if (path.endsWith('_view.dart')) {
    final className = _pathToClassName(
      path.split('/').last.replaceAll('.dart', ''),
    );
    return '''
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '$className',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Color(0xFF050816),
    );
  }
}
''';
  }

  if (path.startsWith('lib/core/theme/app_theme')) {
    return '''
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050816),
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Cairo',
      );

  static ThemeData get light => ThemeData.light().copyWith(
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Cairo',
      );
}
''';
  }

  // default simple file
  return '''
// TODO: implement ${path.split('/').last}
''';
}

String _pathToClassName(String snake) {
  // e.g. dashboard_view -> DashboardView
  return snake
      .split('_')
      .map((e) => e.isEmpty ? '' : e[0].toUpperCase() + e.substring(1))
      .join();
}
