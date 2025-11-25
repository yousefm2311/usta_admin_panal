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
import '../../modules/notifications/views/templates_view.dart';
import '../../modules/payments/views/payments_list_view.dart';
import '../../modules/payments/views/transactions_view.dart';
import '../../modules/payments/views/payout_requests_view.dart';
import '../../modules/payments/views/payout_details_view.dart';
import '../../modules/payments/views/wallet_summary_view.dart';
import '../../modules/requests/views/request_details_view.dart';
import '../../modules/requests/views/requests_list_view.dart';
import '../../modules/reviews/views/reviews_list_view.dart';
import '../../modules/settings/views/settings_commission_view.dart';
import '../../modules/settings/views/settings_general_view.dart';
import '../../modules/withdrawals/views/withdrawals_list_view.dart';
import '../../modules/orders/views/all_orders_view.dart';
import '../../modules/orders/views/order_details_view.dart';
import '../../modules/orders/views/timeline_view.dart';
import '../../modules/complaints/views/complaints_list_view.dart';
import '../../modules/complaints/views/complaint_details_view.dart';
import '../../modules/marketing/views/coupons_view.dart';
import '../../modules/marketing/views/referral_view.dart';
import '../../modules/marketing/views/rewards_view.dart';
import '../../modules/roles/views/roles_list_view.dart';
import '../../modules/roles/views/role_permissions_view.dart';
import '../../modules/logs/views/activity_logs_view.dart';
import '../../modules/logs/views/system_health_view.dart';
import '../../modules/profile/views/admin_profile_view.dart';
import '../../modules/auth/views/reset_password_view.dart';
import '../../modules/auth/views/choose_role_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: '/login', page: () => const LoginView()),
    GetPage(name: '/reset', page: () => const ResetPasswordView()),
    GetPage(name: '/choose-role', page: () => const ChooseRoleView()),
    GetPage(name: '/dashboard', page: () => const DashboardView()),

    // Orders
    GetPage(name: '/orders', page: () => const AllOrdersView()),
    GetPage(name: '/order/details', page: () => const OrderDetailsView()),
    GetPage(name: '/order/timeline', page: () => const OrderTimelineView()),

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
    GetPage(name: '/transactions', page: () => const TransactionsView()),
    GetPage(name: '/payouts', page: () => const PayoutRequestsView()),
    GetPage(name: '/payout/details', page: () => const PayoutDetailsView()),
    GetPage(name: '/wallets', page: () => const WalletSummaryView()),
    GetPage(name: '/withdrawals', page: () => const WithdrawalsListView()),

    // Categories
    GetPage(name: '/categories', page: () => const CategoriesListView()),
    GetPage(name: '/category/add', page: () => const CategoryFormView()),

    // Reviews
    GetPage(name: '/reviews', page: () => const ReviewsListView()),

    // Notifications
    GetPage(name: '/notifications', page: () => const NotificationsCenterView()),
    GetPage(name: '/notifications/send', page: () => const SendNotificationView()),
    GetPage(name: '/notifications/templates', page: () => const NotificationTemplatesView()),

    // Analytics
    GetPage(name: '/analytics', page: () => const AnalyticsOverviewView()),

    // Settings
    GetPage(name: '/settings', page: () => const SettingsGeneralView()),
    GetPage(name: '/settings/commission', page: () => const SettingsCommissionView()),

    // Complaints
    GetPage(name: '/complaints', page: () => const ComplaintsListView()),
    GetPage(name: '/complaint/details', page: () => const ComplaintDetailsView()),

    // Marketing
    GetPage(name: '/marketing/coupons', page: () => const CouponsView()),
    GetPage(name: '/marketing/referral', page: () => const ReferralView()),
    GetPage(name: '/marketing/rewards', page: () => const RewardsView()),

    // Roles
    GetPage(name: '/roles', page: () => const RolesListView()),
    GetPage(name: '/roles/permissions', page: () => const RolePermissionsView()),

    // Logs
    GetPage(name: '/logs/activity', page: () => const ActivityLogsView()),
    GetPage(name: '/logs/health', page: () => const SystemHealthView()),

    // Profile
    GetPage(name: '/profile', page: () => const AdminProfileView()),

    // AI
    GetPage(name: '/ai/reviews', page: () => const AIReviewsInsightsView()),
    GetPage(name: '/ai/top-artisans', page: () => const AITopArtisansView()),

  ];
}
