import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/notify.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late final OrderDetailsController controller;

  String orderId = '';

  // Keep these out of build()
  final RxString timelineStatus = 'in_progress'.obs;
  final TextEditingController timelineNoteCtrl = TextEditingController();
  final TextEditingController actionNoteCtrl = TextEditingController();
  final TextEditingController msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrderDetailsController());

    // Delay reading arguments until after first frame (safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      orderId = (args?['_id'] ?? args?['id'] ?? '').toString();

      if (orderId.isNotEmpty) {
        controller.load(orderId);
      } else {
        controller.error.value = 'No ID'.tr;
      }
    });
  }

  @override
  void dispose() {
    timelineNoteCtrl.dispose();
    actionNoteCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CardLoading(lines: 6),
              SizedBox(height: AppSizes.md),
              CardLoading(lines: 10),
              SizedBox(height: AppSizes.md),
              CardLoading(lines: 6),
              SizedBox(height: AppSizes.md),
              ListLoading(rows: 2),
              SizedBox(height: AppSizes.md),
              CardLoading(lines: 8),
            ],
          );
        }

        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final order = controller.order.value;
        if (order == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final price =
            double.tryParse(
              (order['amount'] ?? order['price'] ?? 0).toString(),
            ) ??
            0;

        final serviceName = (order['serviceType'] ?? order['service'] ?? '')
            .toString();
        final status = (order['status'] ?? '').toString();
        final statusKey = _normalizeStatusKey(status);
        final createdAt = formatDateString(order['createdAt']);

        final artisanName = (order['artisan']?['name'] ?? 'No artisan')
            .toString();
        final artisanPhone = (order['artisan']?['phone'] ?? '').toString();

        final customerName = (order['customer']?['name'] ?? '').toString();
        final customerPhone = (order['customer']?['phone'] ?? '').toString();

        final messages = controller.messages;
        final images = _extractImages(order);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageTitle('Order Details'.tr),
              const SizedBox(height: AppSizes.sm),

              // Header summary card
              _card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBadge(Icons.build_rounded, AppColors.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Wrap(
                            runSpacing: 6,
                            spacing: 10,
                            children: [
                              if (customerName.isNotEmpty)
                                _miniInfo(
                                  icon: Icons.person_outline,
                                  text: customerPhone.isNotEmpty
                                      ? '$customerName ($customerPhone)'
                                      : customerName,
                                ),
                              _miniInfo(
                                icon: Icons.handyman_outlined,
                                text: artisanPhone.isNotEmpty
                                    ? '$artisanName ($artisanPhone)'
                                    : artisanName,
                              ),
                              _miniInfo(
                                icon: Icons.calendar_month_outlined,
                                text: '${"created".tr}: $createdAt',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _statusChip(status),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Timeline card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Status timeline'.tr),
                    const SizedBox(height: AppSizes.sm),

                    Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: AppSizes.xs,
                      children: controller.timeline
                          .map(
                            (step) =>
                                _statusChip((step['status'] ?? '').toString()),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: AppSizes.md),
                    _divider(),

                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Add timeline step'.tr,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),

                    LayoutBuilder(
                      builder: (ctx, c) {
                        final isNarrow = c.maxWidth < 520;
                        final dropdown = Obx(
                          () => DropdownButtonFormField<String>(
                            value: timelineStatus.value,
                            dropdownColor: AppColors.card,
                            decoration: InputDecoration(labelText: 'Status'.tr),
                            items:
                                [
                                  'pending',
                                  'accepted',
                                  'assigned',
                                  'in_progress',
                                  'completed',
                                  'cancelled',
                                  'closed',
                                ].map((v) {
                                  return DropdownMenuItem(
                                    value: v,
                                    child: Text(v.tr),
                                  );
                                }).toList(),
                            onChanged: (v) {
                              if (v != null) timelineStatus.value = v;
                            },
                          ),
                        );

                        final note = TextField(
                          controller: timelineNoteCtrl,
                          style: TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            labelText: 'Note'.tr,
                            hintText: 'Optional'.tr,
                          ),
                        );

                        final btn = Obx(() {
                          final isBusy = controller.addingTimeline.value;
                          return ElevatedButton.icon(
                            onPressed: isBusy || orderId.isEmpty
                                ? null
                                : () {
                                    controller.addTimeline(
                                      orderId,
                                      status: timelineStatus.value,
                                      note: timelineNoteCtrl.text.trim(),
                                    );
                                    timelineNoteCtrl.clear();
                                  },
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: Text(isBusy ? 'Adding...'.tr : 'Add'.tr),
                          );
                        });

                        if (isNarrow) {
                          return Column(
                            children: [
                              dropdown,
                              const SizedBox(height: AppSizes.sm),
                              note,
                              const SizedBox(height: AppSizes.sm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: btn,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            SizedBox(width: 220, child: dropdown),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(child: note),
                            const SizedBox(width: AppSizes.sm),
                            btn,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Images
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Images'.tr),
                    const SizedBox(height: AppSizes.sm),
                    if (images.isEmpty)
                      Text(
                        'No data'.tr,
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      Wrap(
                        spacing: AppSizes.sm,
                        runSpacing: AppSizes.sm,
                        children: images.map(_imageTile).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Payment info
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Payment info'.tr),
                    const SizedBox(height: AppSizes.sm),
                    _priceRow(
                      'Service total'.tr,
                      'EG ${price.toStringAsFixed(0)}',
                    ),
                    _priceRow(
                      'Platform fee'.tr,
                      'EG ${(price * 0.1).toStringAsFixed(2)}',
                    ),
                    _divider(),
                    _priceRow(
                      'Total'.tr,
                      'EG ${(price * 1.1).toStringAsFixed(2)}',
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Actions
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Actions'.tr),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: actionNoteCtrl,
                      style: TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Note'.tr,
                        hintText: 'Optional'.tr,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: [
                        Obx(() {
                          final isBusy = controller.cancelling.value;
                          final disabled = _isCancelDisabled(statusKey) ||
                              controller.closing.value;
                          return ElevatedButton.icon(
                            onPressed: disabled || isBusy || orderId.isEmpty
                                ? null
                                : () => controller.cancel(
                                      orderId,
                                      note: actionNoteCtrl.text.trim().isEmpty
                                          ? null
                                          : actionNoteCtrl.text.trim(),
                                      reason: 'Canceled by admin',
                                    ),
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cancel_outlined),
                            label: Text(
                              isBusy ? 'Cancelling...'.tr : 'Cancel'.tr,
                            ),
                          );
                        }),
                        Obx(() {
                          final isBusy = controller.closing.value;
                          final disabled =
                              _isCloseDisabled(statusKey) ||
                                  controller.cancelling.value;
                          return OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.border),
                              foregroundColor: AppColors.text,
                            ),
                            onPressed: disabled || isBusy || orderId.isEmpty
                                ? null
                                : () => controller.close(
                                      orderId,
                                      note: actionNoteCtrl.text.trim().isEmpty
                                          ? null
                                          : actionNoteCtrl.text.trim(),
                                    ),
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              isBusy ? 'Closing...'.tr : 'Close order'.tr,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Obx(() {
                      final isBusy =
                          controller.cancelling.value || controller.closing.value;
                      if (!isBusy) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.cancelling.value
                                ? 'Cancelling...'.tr
                                : 'Closing...'.tr,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Chat
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Chat (view only)'.tr),
                    const SizedBox(height: AppSizes.sm),

                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(
                          AppSizes.inputRadius,
                        ),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.6),
                        ),
                      ),
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'No messages'.tr,
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              itemCount: messages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final m =
                                    messages[i] as Map<String, dynamic>? ?? {};
                                final sender = (m['sender'] ?? '').toString();
                                final text = (m['message'] ?? '').toString();
                                final ts = m['createdAt'] ?? m['time'];

                                return _chatBubble(
                                  sender: sender,
                                  message: text,
                                  time: ts == null ? '' : formatDateString(ts),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // send notification message
                    Obx(
                      () {
                        final isBusy = controller.sendingMessage.value;
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: msgCtrl,
                                style: TextStyle(color: AppColors.text),
                                decoration: InputDecoration(
                                  hintText: 'Type notification message'.tr,
                                ),
                                onSubmitted: (_) {
                                  if (!isBusy) _sendMsg();
                                },
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            ElevatedButton(
                              onPressed: isBusy ? null : _sendMsg,
                              child: isBusy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Send'.tr),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _sendMsg() {
    final text = msgCtrl.text.trim();
    if (orderId.isEmpty) {
      showError('No ID'.tr);
      return;
    }
    if (text.isEmpty) return;
    controller.sendMessage(orderId, text);
    msgCtrl.clear();
  }

  // ---------- UI helpers ----------

  Widget _pageTitle(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.text,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
  );

  Widget _divider() => Divider(color: AppColors.border);

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _miniInfo({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _chatBubble({
    required String sender,
    required String message,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sender.isNotEmpty)
            Row(
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
              ],
            ),
          if (sender.isNotEmpty) const SizedBox(height: 6),
          Text(
            message.isEmpty ? '-' : message,
            style: TextStyle(color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
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
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase().trim()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'assigned':
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'pending':
      case 'new':
        color = AppColors.warning;
        break;
      case 'in progress':
      case 'in_progress':
        color = Colors.amber;
        break;
      case 'canceled':
      case 'cancelled':
      case 'canceled_by_admin':
        color = AppColors.danger;
        break;
      case 'closed':
        color = AppColors.textMuted;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _imageTile(String url) {
    final resolved = _normalizeImageUrl(url);
    final widget = resolved.startsWith('data:')
        ? _buildDataImage(resolved)
        : Image.network(
            resolved,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageFallback(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      child: Container(
        width: 160,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.overlay,
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: widget,
      ),
    );
  }

  Widget _buildDataImage(String dataUri) {
    final bytes = _dataUriToBytes(dataUri);
    if (bytes == null) return _imageFallback();
    return Image.memory(bytes, fit: BoxFit.cover);
  }

  Widget _imageFallback() {
    return Center(
      child: Text(
        'Image'.tr,
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }

  Uint8List? _dataUriToBytes(String dataUri) {
    try {
      final uri = Uri.parse(dataUri);
      return uri.data?.contentAsBytes();
    } catch (_) {
      return null;
    }
  }

  List<String> _extractImages(Map<String, dynamic> order) {
    final List<String> output = [];
    final sources = <dynamic>[
      order['images'],
      order['image'],
      order['photos'],
      order['attachments'],
      order['media'],
      order['files'],
      order['gallery'],
      (order['request'] is Map) ? (order['request'] as Map)['images'] : null,
      (order['request'] is Map) ? (order['request'] as Map)['photos'] : null,
    ];

    for (final src in sources) {
      _collectImages(src, output);
    }

    final uniq = <String>{};
    for (final item in output) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) {
        uniq.add(trimmed);
      }
    }
    return uniq.toList();
  }

  void _collectImages(dynamic source, List<String> output) {
    if (source == null) return;

    if (source is String || source is num) {
      output.add(source.toString());
      return;
    }

    if (source is Map) {
      const keys = [
        'url',
        'image',
        'path',
        'src',
        'file',
        'thumbnail',
        'preview',
        'location',
        'link',
      ];
      for (final key in keys) {
        final value = source[key];
        if (value is String || value is num) {
          output.add(value.toString());
        }
      }

      const nestedKeys = ['images', 'photos', 'files', 'attachments', 'media'];
      for (final key in nestedKeys) {
        _collectImages(source[key], output);
      }
      return;
    }

    if (source is List) {
      for (final item in source) {
        _collectImages(item, output);
      }
    }
  }

  String _normalizeImageUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http') || value.startsWith('data:')) return value;
    return value.startsWith('/')
        ? '${AppConfig.baseUrl}$value'
        : '${AppConfig.baseUrl}/$value';
  }

  String _normalizeStatusKey(String status) {
    final normalized = status
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'inprogress':
      case 'in_progress':
        return 'in_progress';
      case 'canceled':
      case 'cancelled':
      case 'canceled_by_admin':
      case 'cancelled_by_admin':
        return 'cancelled';
      default:
        return normalized;
    }
  }

  bool _isCancelDisabled(String statusKey) {
    return statusKey == 'cancelled' || statusKey == 'closed';
  }

  bool _isCloseDisabled(String statusKey) {
    return statusKey == 'closed' || statusKey == 'cancelled';
  }
}
