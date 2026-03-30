import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../widgets/modules/ai/views/ai_fraud_detection_view.dart';
import '../../widgets/modules/ai/views/ai_reviews_insights_view.dart';
import '../../widgets/modules/ai/views/ai_top_artisans_view.dart';
import '../../widgets/modules/ai/views/ai_word_cloud_view.dart';
import '../../widgets/modules/analytics/views/analytics_overview_view.dart';
import '../../widgets/modules/artisans/views/artisan_details_view.dart';
import '../../widgets/modules/artisans/views/artisans_list_view.dart';
import '../../widgets/modules/auth/views/choose_role_view.dart';
import '../../widgets/modules/auth/views/login_view.dart';
import '../../widgets/modules/auth/views/reset_password_view.dart';
import '../../widgets/modules/categories/views/categories_list_view.dart';
import '../../widgets/modules/categories/views/category_form_view.dart';
import '../../widgets/modules/complaints/views/complaint_details_view.dart';
import '../../widgets/modules/complaints/views/complaints_list_view.dart';
import '../../widgets/modules/customers/views/customer_details_view.dart';
import '../../widgets/modules/customers/views/customer_orders_view.dart';
import '../../widgets/modules/customers/views/customers_list_view.dart';
import '../../widgets/modules/dashboard/views/dashboard_view.dart';
import '../../widgets/modules/logs/views/activity_logs_view.dart';
import '../../widgets/modules/logs/views/system_health_view.dart';
import '../../widgets/modules/marketing/views/coupons_view.dart';
import '../../widgets/modules/marketing/views/referral_view.dart';
import '../../widgets/modules/marketing/views/rewards_view.dart';
import '../../widgets/modules/notifications/views/notifications_broadcast_view.dart';
import '../../widgets/modules/notifications/views/notifications_center_view.dart';
import '../../widgets/modules/notifications/views/notifications_tokens_view.dart';
import '../../widgets/modules/notifications/views/send_notification_view.dart';
import '../../widgets/modules/notifications/views/templates_view.dart';
import '../../widgets/modules/orders/views/all_orders_view.dart';
import '../../widgets/modules/orders/views/order_details_view.dart';
import '../../widgets/modules/orders/views/timeline_view.dart';
import '../../widgets/modules/payments/views/payment_details_view.dart';
import '../../widgets/modules/payments/views/payments_list_view.dart';
import '../../widgets/modules/payments/views/payout_details_view.dart';
import '../../widgets/modules/payments/views/payout_requests_view.dart';
import '../../widgets/modules/payments/views/transactions_view.dart';
import '../../widgets/modules/payments/views/wallet_summary_view.dart';
import '../../widgets/modules/profile/views/admin_profile_view.dart';
import '../../widgets/modules/reports/views/report_details_view.dart';
import '../../widgets/modules/reports/views/reports_list_view.dart';
import '../../widgets/modules/requests/views/request_details_view.dart';
import '../../widgets/modules/requests/views/requests_list_view.dart';
import '../../widgets/modules/reviews/views/reviews_list_view.dart';
import '../../widgets/modules/roles/views/role_permissions_view.dart';
import '../../widgets/modules/roles/views/roles_list_view.dart';
import '../../widgets/modules/settings/views/change_password_view.dart';
import '../../widgets/modules/settings/views/settings_commission_view.dart';
import '../../widgets/modules/settings/views/settings_features_view.dart';
import '../../widgets/modules/settings/views/settings_general_view.dart';
import '../../widgets/modules/settings/views/settings_security_view.dart';
import '../../widgets/modules/withdrawals/views/withdrawals_list_view.dart';
import '../../widgets/theme_rebuild.dart';

class AppPages {
  static GetPage _themed(String name, WidgetBuilder builder) {
    return GetPage(name: name, page: () => ThemeRebuild(builder: builder));
  }

  static final pages = <GetPage>[
    _themed('/login', (_) => LoginView()),
    _themed('/reset', (_) => ResetPasswordView()),
    _themed('/choose-role', (_) => ChooseRoleView()),
    _themed('/dashboard', (_) => DashboardView()),

    // Orders
    _themed('/orders', (_) => AllOrdersView()),
    _themed('/order/details', (_) => OrderDetailsView()),
    _themed('/order/timeline', (_) => OrderTimelineView()),

    // Customers
    _themed('/customers', (_) => CustomersListView()),
    _themed('/customer/details', (_) => CustomerDetailsView()),
    _themed('/customer/orders', (_) => CustomerOrdersView()),

    // Artisans
    _themed('/artisans', (_) => ArtisansListView()),
    _themed('/artisan/details', (_) => ArtisanDetailsView()),

    // Requests
    _themed('/requests', (_) => RequestsListView()),
    _themed('/request/details', (_) => RequestDetailsView()),

    // Payments & Withdrawals
    _themed('/payments', (_) => PaymentsListView()),
    _themed('/transactions', (_) => TransactionsView()),
    _themed('/payouts', (_) => PayoutRequestsView()),
    _themed('/payout/details', (_) => PayoutDetailsView()),
    _themed('/payment/details', (_) => PaymentDetailsView()),
    _themed('/wallets', (_) => WalletSummaryView()),
    _themed('/withdrawals', (_) => WithdrawalsListView()),

    // Categories
    _themed('/categories', (_) => CategoriesListView()),
    _themed('/category/add', (_) => CategoryFormView()),

    // Reviews
    _themed('/reviews', (_) => ReviewsListView()),

    // Reports
    _themed('/reports', (_) => ReportsListView()),
    _themed('/report/details', (_) => ReportDetailsView()),

    // Notifications
    _themed('/notifications', (_) => NotificationsCenterView()),
    _themed('/notifications/send', (_) => SendNotificationView()),
    _themed('/notifications/templates', (_) => NotificationTemplatesView()),
    _themed('/notifications/broadcast', (_) => NotificationsBroadcastView()),
    _themed('/notifications/tokens', (_) => NotificationsTokensView()),

    // Analytics
    _themed('/analytics', (_) => AnalyticsOverviewView()),

    // Settings
    _themed('/settings', (_) => SettingsGeneralView()),
    _themed('/settings/commission', (_) => SettingsCommissionView()),
    _themed('/settings/features', (_) => SettingsFeaturesView()),
    _themed('/settings/security', (_) => SettingsSecurityView()),
    _themed('/settings/change-password', (_) => ChangePasswordView()),

    // Complaints
    _themed('/complaints', (_) => ComplaintsListView()),
    _themed('/complaint/details', (_) => ComplaintDetailsView()),

    // Marketing
    _themed('/marketing/coupons', (_) => CouponsView()),
    _themed('/marketing/referral', (_) => ReferralView()),
    _themed('/marketing/rewards', (_) => RewardsView()),

    // Roles
    _themed('/roles', (_) => RolesListView()),
    _themed('/roles/permissions', (_) => RolePermissionsView()),

    // Logs
    _themed('/logs/activity', (_) => ActivityLogsView()),
    _themed('/logs/health', (_) => SystemHealthView()),

    // Profile
    _themed('/profile', (_) => AdminProfileView()),

    // AI
    _themed('/ai/reviews', (_) => AIReviewsInsightsView()),
    _themed('/ai/top-artisans', (_) => AITopArtisansView()),
    _themed('/ai/fraud', (_) => AIFraudDetectionView()),
    _themed('/ai/word-cloud', (_) => AIWordCloudView()),

  ];
}
