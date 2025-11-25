import 'package:flutter/material.dart';

import '../models/admin_user_model.dart';
import '../models/analytics_model.dart';
import '../models/artisan_model.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/request_model.dart';
import '../models/review_model.dart';
import '../models/withdrawal_model.dart';

class MockData {
  static const adminUser = AdminUserModel(
    name: 'Aisha Noor',
    email: 'admin@usta.com',
    avatarUrl: '',
  );

  static final List<CustomerModel> customers = [
    const CustomerModel(
      name: 'Layla Ibrahim',
      phone: '+971 50 123 4567',
      requests: 18,
      status: 'Active',
    ),
    const CustomerModel(
      name: 'Omar Khaled',
      phone: '+971 55 234 9876',
      requests: 12,
      status: 'Active',
    ),
    const CustomerModel(
      name: 'Sara Mansour',
      phone: '+971 56 887 1234',
      requests: 7,
      status: 'Blocked',
    ),
    const CustomerModel(
      name: 'Yousef Ali',
      phone: '+971 50 998 4412',
      requests: 22,
      status: 'Active',
    ),
    const CustomerModel(
      name: 'Maryam Hassan',
      phone: '+971 52 114 8899',
      requests: 9,
      status: 'Active',
    ),
  ];

  static final List<ArtisanModel> artisans = [
    const ArtisanModel(
      name: 'Hassan Mahmoud',
      category: 'Electrician',
      rating: 4.9,
      status: 'Approved',
      completed: 212,
      documents: ['Trade License', 'Emirates ID'],
    ),
    const ArtisanModel(
      name: 'Rami Zidan',
      category: 'Plumbing',
      rating: 4.7,
      status: 'Pending',
      completed: 144,
      documents: ['Trade License'],
    ),
    const ArtisanModel(
      name: 'Noor Salem',
      category: 'Cleaning',
      rating: 4.8,
      status: 'Approved',
      completed: 188,
      documents: ['Trade License', 'Insurance'],
    ),
    const ArtisanModel(
      name: 'Walid Hakim',
      category: 'Painting',
      rating: 4.6,
      status: 'Rejected',
      completed: 92,
    ),
  ];

  static final List<RequestModel> requests = [
    RequestModel(
      service: 'Air conditioner maintenance',
      customer: customers[0].name,
      artisan: artisans[0].name,
      status: 'In progress',
      date: DateTime(2025, 10, 21),
      price: 450.0,
    ),
    RequestModel(
      service: 'Apartment deep cleaning',
      customer: customers[2].name,
      artisan: artisans[2].name,
      status: 'Completed',
      date: DateTime(2025, 10, 19),
      price: 320.0,
    ),
    RequestModel(
      service: 'Water leak fix',
      customer: customers[1].name,
      artisan: artisans[1].name,
      status: 'Pending',
      date: DateTime(2025, 10, 22),
      price: 280.0,
    ),
    RequestModel(
      service: 'Villa painting consultation',
      customer: customers[4].name,
      artisan: artisans[3].name,
      status: 'Accepted',
      date: DateTime(2025, 10, 18),
      price: 150.0,
    ),
    RequestModel(
      service: 'Electric socket upgrade',
      customer: customers[3].name,
      artisan: artisans[0].name,
      status: 'Completed',
      date: DateTime(2025, 10, 16),
      price: 190.0,
    ),
  ];

  static final List<PaymentModel> payments = [
    PaymentModel(
      customer: customers[0].name,
      amount: 420.0,
      method: 'Card',
      date: DateTime(2025, 10, 18),
    ),
    PaymentModel(
      customer: customers[1].name,
      amount: 280.0,
      method: 'Cash',
      date: DateTime(2025, 10, 17),
    ),
    PaymentModel(
      customer: customers[2].name,
      amount: 320.0,
      method: 'Apple Pay',
      date: DateTime(2025, 10, 15),
    ),
    PaymentModel(
      customer: customers[3].name,
      amount: 190.0,
      method: 'Card',
      date: DateTime(2025, 10, 10),
    ),
  ];

  static final List<WithdrawalModel> withdrawals = [
    const WithdrawalModel(
      artisan: 'Hassan Mahmoud',
      amount: 980.0,
      iban: 'AE12 3456 7890 1234 5678 90',
      status: 'Pending',
    ),
    const WithdrawalModel(
      artisan: 'Noor Salem',
      amount: 720.0,
      iban: 'AE45 6789 1234 5678 9012 34',
      status: 'Approved',
    ),
    const WithdrawalModel(
      artisan: 'Rami Zidan',
      amount: 450.0,
      iban: 'AE90 1111 2222 3333 4444 55',
      status: 'Pending',
    ),
  ];

  static final List<CategoryModel> categories = const [
    CategoryModel(name: 'Cleaning', icon: Icons.cleaning_services, color: Colors.teal),
    CategoryModel(name: 'Plumbing', icon: Icons.plumbing, color: Colors.blue),
    CategoryModel(name: 'Electrician', icon: Icons.electrical_services, color: Colors.amber),
    CategoryModel(name: 'Painting', icon: Icons.format_paint, color: Colors.pinkAccent),
    CategoryModel(name: 'HVAC', icon: Icons.ac_unit, color: Colors.cyan),
  ];

  static final List<ReviewModel> reviews = [
    ReviewModel(
      text: 'Great service, arrived on time and finished early.',
      rating: 5.0,
      customer: customers[0].name,
      artisan: artisans[0].name,
      date: DateTime(2025, 10, 18),
    ),
    ReviewModel(
      text: 'Professional and polite team.',
      rating: 4.5,
      customer: customers[1].name,
      artisan: artisans[2].name,
      date: DateTime(2025, 10, 16),
    ),
    ReviewModel(
      text: 'Issue resolved but follow-up was slow.',
      rating: 3.5,
      customer: customers[2].name,
      artisan: artisans[1].name,
      date: DateTime(2025, 10, 14),
    ),
  ];

  static final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'New version of the USTA app is live.',
      target: 'All Users',
      date: DateTime(2025, 10, 20),
    ),
    NotificationModel(
      title: 'Service request #120 updated to Completed.',
      target: 'Customer',
      date: DateTime(2025, 10, 18),
    ),
    NotificationModel(
      title: 'Reminder: Upload missing documents.',
      target: 'Artisans',
      date: DateTime(2025, 10, 17),
    ),
  ];

  static final List<AnalyticsModel> analytics = [
    const AnalyticsModel(month: 'Jan', requests: 120.0, earnings: 4800.0),
    const AnalyticsModel(month: 'Feb', requests: 98.0, earnings: 4300.0),
    const AnalyticsModel(month: 'Mar', requests: 150.0, earnings: 6200.0),
    const AnalyticsModel(month: 'Apr', requests: 132.0, earnings: 5700.0),
    const AnalyticsModel(month: 'May', requests: 165.0, earnings: 7100.0),
    const AnalyticsModel(month: 'Jun', requests: 142.0, earnings: 6400.0),
    const AnalyticsModel(month: 'Jul', requests: 178.0, earnings: 7600.0),
    const AnalyticsModel(month: 'Aug', requests: 192.0, earnings: 8000.0),
    const AnalyticsModel(month: 'Sep', requests: 164.0, earnings: 6900.0),
    const AnalyticsModel(month: 'Oct', requests: 188.0, earnings: 8200.0),
    const AnalyticsModel(month: 'Nov', requests: 175.0, earnings: 7800.0),
    const AnalyticsModel(month: 'Dec', requests: 210.0, earnings: 9100.0),
  ];

  static const Map<String, double> sentiment = {
    'Positive': 68.0,
    'Neutral': 21.0,
    'Negative': 11.0,
  };
}
