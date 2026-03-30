import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/notify.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/request_details_controller.dart';

class RequestDetailsView extends StatefulWidget {
  const RequestDetailsView({super.key});

  @override
  State<RequestDetailsView> createState() => _RequestDetailsViewState();
}

class _RequestDetailsViewState extends State<RequestDetailsView> {
  late final RequestDetailsController controller;

  String requestId = '';
  bool loadedOnce = false;

  // ✅ keep controllers in state (no rebuild reset)
  final msgController = TextEditingController();
  final timelineNote = TextEditingController();
  final actionNote = TextEditingController();

  // ✅ keep status in state
  final RxString timelineStatus = 'pending'.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RequestDetailsController());
  }

  @override
  void dispose() {
    msgController.dispose();
    timelineNote.dispose();
    actionNote.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    requestId = (args?['_id'] ?? args?['id'] ?? '').toString();
    if (requestId.isNotEmpty) {
      controller.load(requestId);
      loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Request details'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 6);
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

        final req = controller.request.value;
        if (req == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final price =
            double.tryParse((req['price'] ?? req['amount'] ?? 0).toString()) ??
            0;
        final images = _extractImages(req);

        final statusKey = _normalizeStatusKey(req['status']);
        final isFinalStatus =
            statusKey == 'closed' || statusKey == 'cancelled';
        final steps = controller.timeline;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Service'.tr),
                          const SizedBox(height: 4),
                          Text(
                            (req['serviceType'] ?? req['service'] ?? '')
                                .toString(),
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            '${'Customer'.tr}: ${_resolveName(req['customer'], fallback: req['customerName'])}',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          Text(
                            '${'Artisan'.tr}: ${_resolveName(req['artisan'], fallback: req['artisanName'])}',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    _statusChip(statusKey),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Timeline
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Status timeline'.tr),
                    const SizedBox(height: AppSizes.sm),

                    if (steps.isEmpty)
                      Text(
                        'No data'.tr,
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      Column(
                        children: List.generate(steps.length, (i) {
                          final step = steps[i] is Map
                              ? Map<String, dynamic>.from(steps[i])
                              : <String, dynamic>{};
                          final label = _normalizeStatusKey(step['status']);
                          final done = i < steps.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.sm),
                            child: _timelineRow(
                              label,
                              step['note'],
                              step['createdAt'],
                              done,
                              isLast: i == steps.length - 1,
                            ),
                          );
                        }),
                      ),

                    const SizedBox(height: AppSizes.md),

                    Row(
                      children: [
                        Obx(
                          () => DropdownButton<String>(
                            value: timelineStatus.value,
                            dropdownColor: AppColors.card,
                            items:
                                const [
                                      'pending',
                                      'accepted',
                                      'assigned',
                                      'in_progress',
                                      'completed',
                                      'cancelled',
                                      'closed',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList()
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.value,
                                        child: Text((item.value ?? '').tr),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => timelineStatus.value =
                                v ?? timelineStatus.value,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: TextField(
                            controller: timelineNote,
                            style: TextStyle(color: AppColors.text),
                            decoration: InputDecoration(hintText: 'Note'.tr),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Obx(() {
                          final isBusy = controller.addingTimeline.value;
                          return ElevatedButton.icon(
                            onPressed: isBusy || requestId.isEmpty
                                ? null
                                : () async {
                                    if (requestId.isEmpty) return;
                                    await controller.addTimeline(
                                      requestId,
                                      status: timelineStatus.value,
                                      note: timelineNote.text.trim(),
                                    );
                                    timelineNote.clear();
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
                        }),
                      ],
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

              // Chat
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Chat (view only)'.tr),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(
                          AppSizes.inputRadius,
                        ),
                      ),
                      child: controller.messages.isNotEmpty
                          ? ListView.separated(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              itemCount: controller.messages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSizes.sm),
                              itemBuilder: (_, i) {
                                final m = controller.messages[i] is Map
                                    ? Map<String, dynamic>.from(
                                        controller.messages[i],
                                      )
                                    : <String, dynamic>{};
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (m['sender'] ?? '').toString(),
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (m['message'] ?? '').toString(),
                                      style: TextStyle(color: AppColors.text),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'No messages'.tr,
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: msgController,
                      style: TextStyle(color: AppColors.text),
                      enabled: !controller.sendingMessage.value,
                      decoration: InputDecoration(
                        hintText: 'Type notification message'.tr,
                      ),
                      onSubmitted: (v) async {
                        final text = v.trim();
                        if (requestId.isEmpty) {
                          showError('No ID');
                          return;
                        }
                        if (text.isEmpty) return;
                        await controller.sendMessage(requestId, text);
                        msgController.clear();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Pricing
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Pricing'.tr),
                    const SizedBox(height: AppSizes.sm),
                    _priceRow(
                      'Base price'.tr,
                      'EG ${price.toStringAsFixed(0)}',
                    ),
                    _priceRow(
                      'VAT 5%'.tr,
                      'EG ${(price * 0.05).toStringAsFixed(2)}',
                    ),
                    Divider(color: AppColors.border),
                    _priceRow(
                      'Total'.tr,
                      'EG ${(price * 1.05).toStringAsFixed(2)}',
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Actions
              Obx(() {
                final isClosing = controller.closing.value;
                final isCancelling = controller.cancelling.value;
                final disableActions = requestId.isEmpty ||
                    isFinalStatus ||
                    isClosing ||
                    isCancelling;

                return Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: disableActions
                          ? null
                          : () => controller.close(
                                requestId,
                                status: 'closed',
                                note: actionNote.text.trim().isEmpty
                                    ? null
                                    : actionNote.text.trim(),
                              ),
                      icon: isClosing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(isClosing ? 'Closing...'.tr : 'Close'.tr),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.text,
                      ),
                      onPressed: disableActions
                          ? null
                          : () => controller.cancel(
                                requestId,
                                reason: 'Canceled by admin',
                                note: actionNote.text.trim().isEmpty
                                    ? null
                                    : actionNote.text.trim(),
                              ),
                      icon: isCancelling
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined),
                      label:
                          Text(isCancelling ? 'Canceling...'.tr : 'Cancel'.tr),
                    ),
                  ],
                );
              }),
              const SizedBox(height: AppSizes.sm),
              TextField(
                controller: actionNote,
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(hintText: 'Note'.tr),
              ),
            ],
          ),
        );
      }),
    );
  }

  // -------- ui helpers --------

  Widget _timelineRow(
    String statusKey,
    dynamic note,
    dynamic createdAt,
    bool done, {
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: done ? AppColors.primary : AppColors.border,
              child: Icon(
                done ? Icons.check : Icons.radio_button_unchecked,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: AppColors.border,
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusKey.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                (note ?? createdAt ?? '').toString(),
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
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

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.text,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  String _resolveName(dynamic value, {dynamic fallback}) {
    if (value is Map<String, dynamic>) {
      return (value['name'] ??
              value['fullName'] ??
              value['phone'] ??
              value['email'] ??
              '')
          .toString();
    }
    return (value ?? fallback ?? '-').toString();
  }

  String _normalizeStatusKey(dynamic raw) {
    final s = (raw ?? '').toString().trim().toLowerCase();
    final normalized = s.replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'inprogress':
      case 'in_progress':
        return 'in_progress';
      case 'canceled':
      case 'cancelled':
        return 'cancelled';
      default:
        return normalized.isEmpty ? 'new' : normalized;
    }
  }

  Widget _statusChip(String key) {
    final color = _statusColor(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        key.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'new':
        return AppColors.warning;
      case 'accepted':
      case 'assigned':
        return Colors.lightBlueAccent;
      case 'in_progress':
        return Colors.amber;
      case 'cancelled':
      case 'closed':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
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

  List<String> _extractImages(Map<String, dynamic> request) {
    final List<String> output = [];
    final sources = <dynamic>[
      request['images'],
      request['image'],
      request['photos'],
      request['attachments'],
      request['media'],
      request['files'],
      request['gallery'],
      (request['request'] is Map) ? (request['request'] as Map)['images'] : null,
      (request['request'] is Map) ? (request['request'] as Map)['photos'] : null,
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
}
