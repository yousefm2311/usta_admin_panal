import 'package:get/get.dart';

import '../../modules/ai/views/ai_reviews_insights_view.dart';
import '../../modules/ai/views/ai_top_artisans_view.dart';
import '../../modules/analytics/views/analytics_overview_view.dart';
import '../../modules/artisans/views/artisan_details_view.dart';
import '../../modules/artisans/views/artisans_list_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/categories/views/categories_list_view.dart';
import '../../modules/categories/views/category_form_view.dart';
import '../../modules/customers/views/customer_details_view.dart';
import '../../modules/customers/views/customers_list_view.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/notifications/views/notifications_center_view.dart';
import '../../modules/notifications/views/send_notification_view.dart';
import '../../modules/payments/views/payments_list_view.dart';
import '../../modules/requests/views/request_details_view.dart';
import '../../modules/requests/views/requests_list_view.dart';
import '../../modules/reviews/views/reviews_list_view.dart';
import '../../modules/settings/views/settings_commission_view.dart';
import '../../modules/settings/views/settings_general_view.dart';
import '../../modules/withdrawals/views/withdrawals_list_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: '/login', page: () => const LoginView()),
    GetPage(name: '/dashboard', page: () => const DashboardView()),

    // Customers
    GetPage(name: '/customers', page: () => const CustomersListView()),
    GetPage(name: '/customer/details', page: () => const CustomerDetailsView()),

    // Artisans
    GetPage(name: '/artisans', page: () => const ArtisansListView()),
    GetPage(name: '/artisan/details', page: () => const ArtisanDetailsView()),

    // Requests
    GetPage(name: '/requests', page: () => const RequestsListView()),
    GetPage(name: '/request/details', page: () => const RequestDetailsView()),

    // Payments & Withdrawals
    GetPage(name: '/payments', page: () => const PaymentsListView()),
    GetPage(name: '/withdrawals', page: () => const WithdrawalsListView()),

    // Categories
    GetPage(name: '/categories', page: () => const CategoriesListView()),
    GetPage(name: '/category/add', page: () => const CategoryFormView()),

    // Reviews
    GetPage(name: '/reviews', page: () => const ReviewsListView()),

    // Notifications
    GetPage(name: '/notifications', page: () => const NotificationsCenterView()),
    GetPage(name: '/notifications/send', page: () => const SendNotificationView()),

    // Analytics
    GetPage(name: '/analytics', page: () => const AnalyticsOverviewView()),

    // Settings
    GetPage(name: '/settings', page: () => const SettingsGeneralView()),
    GetPage(name: '/settings/commission', page: () => const SettingsCommissionView()),

    // AI
    GetPage(name: '/ai/reviews', page: () => const AIReviewsInsightsView()),
    GetPage(name: '/ai/top-artisans', page: () => const AITopArtisansView()),

  ];
}
