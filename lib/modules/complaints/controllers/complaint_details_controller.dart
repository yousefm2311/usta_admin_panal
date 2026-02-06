import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/complaints_service.dart';

class ComplaintDetailsController extends GetxController {
  final ComplaintsService _service;
  ComplaintDetailsController({ComplaintsService? service})
    : _service = service ?? ComplaintsService();

  final complaint = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();
  final supportAgents = <Map<String, String>>[].obs;
  final agentsLoading = false.obs;
  final selectedAgentId = ''.obs;
  final assigningToSupportLoading = false.obs;
  final closingLoading = false.obs;
  final assigningAgentLoading = false.obs;
  final savingNoteLoading = false.obs;
  final sendingMessageLoading = false.obs;

  bool get anyActionLoading =>
      assigningToSupportLoading.value ||
      closingLoading.value ||
      assigningAgentLoading.value ||
      savingNoteLoading.value ||
      sendingMessageLoading.value;

  Future<void> load(String id, {bool showLoading = true}) async {
    if (id.trim().isEmpty) return;
    if (showLoading) {
      loading.value = true;
    }
    error.value = null;
    try {
      final res = await _service.details(id);
      final data = res.data;
      final parsed = data is Map<String, dynamic>
          ? (data['complaint'] ?? data['data'] ?? data)
          : null;
      complaint.value = parsed is Map<String, dynamic>
          ? Map<String, dynamic>.from(parsed)
          : null;
      _syncSelectedAgentFromComplaint();
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      if (showLoading) {
        loading.value = false;
      }
    }
  }

  Future<void> updateStatus(String id, String status) async {
    if (id.trim().isEmpty) return;
    final target = status.toLowerCase().trim() == 'assigned'
        ? assigningToSupportLoading
        : closingLoading;
    if (target.value) return;
    target.value = true;
    try {
      await _service.updateStatus(id, status);
      showSuccess('Success'.tr);
      await load(id, showLoading: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      target.value = false;
    }
  }

  Future<void> addMessage(String id, String message) async {
    if (id.trim().isEmpty || message.trim().isEmpty) return;
    if (sendingMessageLoading.value) return;
    sendingMessageLoading.value = true;
    try {
      await _service.addMessage(id, {'message': message.trim()});
      await load(id, showLoading: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      sendingMessageLoading.value = false;
    }
  }

  Future<void> assignAgent(String id, String agentId) async {
    final selected = agentId.trim();
    if (id.trim().isEmpty) return;
    if (selected.isEmpty) {
      showError('Agent ID required'.tr);
      return;
    }
    if (assigningAgentLoading.value) return;
    assigningAgentLoading.value = true;
    try {
      await _service.assign(id, selected);
      showSuccess('Success'.tr);
      await load(id, showLoading: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      assigningAgentLoading.value = false;
    }
  }

  Future<void> addNote(String id, String note) async {
    if (id.trim().isEmpty) return;
    final value = note.trim();
    if (value.isEmpty) {
      showError('Note is required'.tr);
      return;
    }
    if (savingNoteLoading.value) return;
    savingNoteLoading.value = true;
    try {
      await _service.addNote(id, value);
      showSuccess('Success'.tr);
      await load(id, showLoading: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      savingNoteLoading.value = false;
    }
  }

  Future<void> loadSupportAgents({bool force = false}) async {
    if (agentsLoading.value) return;
    if (!force && supportAgents.isNotEmpty) return;

    agentsLoading.value = true;
    try {
      final map = <String, String>{};

      void addAgent({required String id, required String name}) {
        final cleanId = id.trim();
        if (cleanId.isEmpty) return;
        final cleanName = _displayName(name, cleanId);
        final existing = map[cleanId];
        if (existing == null || _looksLikeAutoLabel(existing)) {
          map[cleanId] = cleanName;
        }
      }

      final current = complaint.value;
      if (current != null) {
        final fromAssignedId = _extractIdFromAny(
          current['agentId'] ??
              current['assignedAgentId'] ??
              current['assignedTo'] ??
              current['assigneeId'] ??
              current['supportAgentId'],
        );
        if (fromAssignedId.isNotEmpty) {
          addAgent(
            id: fromAssignedId,
            name: _extractName(
              current['assignedAgent'] ??
                  current['assignedTo'] ??
                  current['agent'],
            ),
          );
        }

        final messages = current['messages'];
        if (messages is List) {
          for (final raw in messages) {
            final m = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
            final type = (m['senderType'] ?? '').toString().toLowerCase();
            if (type != 'admin') continue;
            final senderId = _extractIdFromAny(m['senderId'] ?? m['sender']);
            if (senderId.isEmpty) continue;
            addAgent(id: senderId, name: _extractName(m['sender']));
          }
        }
      }

      try {
        final meRes = await _service.me();
        final data = meRes.data;
        final me = data is Map<String, dynamic>
            ? (data['admin'] ?? data['data'] ?? data)
            : null;
        if (me is Map<String, dynamic>) {
          final id = _extractIdFromAny(me['_id'] ?? me['id']);
          if (id.isNotEmpty) {
            addAgent(id: id, name: _extractName(me));
          }
        }
      } catch (_) {}

      try {
        final logsRes = await _service.activityLogs();
        final data = logsRes.data;
        final rawList = data is Map<String, dynamic>
            ? (data['data'] ?? data['logs'] ?? const [])
            : const [];
        if (rawList is List) {
          for (final raw in rawList) {
            final log = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
            final actor = log['actor'] is Map<String, dynamic>
                ? log['actor'] as Map<String, dynamic>
                : <String, dynamic>{};
            final type = (actor['type'] ?? '').toString().toLowerCase();
            if (type != 'admin') continue;
            final id = _extractIdFromAny(actor['id'] ?? actor['_id']);
            if (id.isEmpty) continue;
            addAgent(id: id, name: _extractName(actor));
          }
        }
      } catch (_) {}

      final list =
          map.entries
              .map((e) => <String, String>{'id': e.key, 'name': e.value})
              .toList()
            ..sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

      supportAgents.assignAll(list);

      if (selectedAgentId.value.isEmpty && supportAgents.isNotEmpty) {
        selectedAgentId.value = supportAgents.first['id'] ?? '';
      } else if (selectedAgentId.value.isNotEmpty &&
          !supportAgents.any((a) => a['id'] == selectedAgentId.value)) {
        selectedAgentId.value = '';
      }
      _syncSelectedAgentFromComplaint();
    } finally {
      agentsLoading.value = false;
    }
  }

  void selectAgent(String id) {
    selectedAgentId.value = id.trim();
  }

  Future<void> assignSelectedAgent(String complaintId) async {
    await assignAgent(complaintId, selectedAgentId.value);
  }

  void _syncSelectedAgentFromComplaint() {
    final data = complaint.value;
    if (data == null) return;
    final assignedId = _extractIdFromAny(
      data['agentId'] ??
          data['assignedAgentId'] ??
          data['assignedTo'] ??
          data['assigneeId'] ??
          data['supportAgentId'] ??
          data['assignedAgent'] ??
          data['agent'],
    );
    if (assignedId.isNotEmpty) {
      selectedAgentId.value = assignedId;
      if (!supportAgents.any((a) => a['id'] == assignedId)) {
        final name = _extractName(
          data['assignedAgent'] ?? data['assignedTo'] ?? data['agent'],
        );
        supportAgents.insert(0, {
          'id': assignedId,
          'name': _displayName(name, assignedId),
        });
      }
      return;
    }

    if (selectedAgentId.value.isEmpty && supportAgents.isNotEmpty) {
      selectedAgentId.value = supportAgents.first['id'] ?? '';
    }
  }

  String _extractIdFromAny(dynamic value) {
    if (value == null) return '';
    if (value is String || value is num) return value.toString();
    if (value is Map<String, dynamic>) {
      final nested = value['_id'] ?? value['id'] ?? value['value'];
      if (nested == null) return '';
      return nested.toString();
    }
    return '';
  }

  String _extractName(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      return value.trim();
    }
    if (value is Map<String, dynamic>) {
      final raw =
          value['name'] ??
          value['fullName'] ??
          value['displayName'] ??
          value['userName'] ??
          value['username'] ??
          value['email'] ??
          value['phone'];
      return (raw ?? '').toString().trim();
    }
    return '';
  }

  String _displayName(String rawName, String id) {
    final name = rawName.trim();
    if (name.isNotEmpty && !_looksLikeObjectId(name)) return name;
    final shortId = id.length > 6 ? id.substring(0, 6) : id;
    return 'Admin #$shortId';
  }

  bool _looksLikeObjectId(String value) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  bool _looksLikeAutoLabel(String value) {
    return value.startsWith('Admin #');
  }

  @override
  void onClose() {
    supportAgents.clear();
    selectedAgentId.value = '';
    super.onClose();
  }
}
