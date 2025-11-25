import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class CustomerDetailsView extends StatefulWidget {
  const CustomerDetailsView({super.key});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  bool active = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final customer = MockData.customers.first;
    final recentRequests = MockData.requests.take(4).toList();

    return AdminLayout(
      title: 'Customer details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              children: [
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary.withOpacity(0.18),
                            child: const Icon(Icons.person, color: AppColors.text, size: 32),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(customer.phone, style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text('Active'.tr, style: const TextStyle(color: AppColors.textMuted)),
                                  Switch(
                                    activeThumbColor: AppColors.primary,
                                    value: active,
                                    onChanged: (v) => setState(() => active = v),
                                  ),
                                ],
                              ),
                              Text(
                                active ? 'Status: Active'.tr : 'Status: Blocked'.tr,
                                style: TextStyle(
                                  color: active ? AppColors.success : AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                       Text(
                        'Preferred location: Dubai Marina • Joined May 2024'.tr,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                _card(
                  child: Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    children: [
                      _miniStat('Total requests label'.tr, '28'),
                      _miniStat('Completed label'.tr, '22'),
                      _miniStat('Canceled'.tr, '3'),
                      _miniStat('Lifetime spend'.tr, 'EG 6,420'),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary.withOpacity(0.18),
                              child: const Icon(Icons.person, color: AppColors.text, size: 32),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(customer.phone, style: const TextStyle(color: AppColors.textMuted)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Text('Active', style: TextStyle(color: AppColors.textMuted)),
                                    Switch(
                                      activeThumbColor: AppColors.primary,
                                      value: active,
                                      onChanged: (v) => setState(() => active = v),
                                    ),
                                  ],
                                ),
                                Text(
                                  active ? 'Status: Active' : 'Status: Blocked',
                                  style: TextStyle(
                                    color: active ? AppColors.success : AppColors.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'Preferred location: Dubai Marina • Joined May 2024',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: _card(
                    child: Wrap(
                      spacing: AppSizes.md,
                      runSpacing: AppSizes.md,
                      children: [
                        _miniStat('Total requests'.tr, '28'),
                        _miniStat('Completed'.tr, '22'),
                        _miniStat('Canceled'.tr, '3'),
                        _miniStat('Lifetime spend'.tr, 'EG 6,420'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSizes.lg),
          _sectionTitle('Last requests'.tr),
          const SizedBox(height: AppSizes.sm),
          _card(
            child: Column(
              children: [
                for (final req in recentRequests)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.build, color: AppColors.textMuted),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(req.service, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                              '${req.artisan} • ${req.status.tr} • EG ${req.price.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${req.date.day}/${req.date.month}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
}
