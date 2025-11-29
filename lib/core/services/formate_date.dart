import 'package:get/get.dart';
import 'package:intl/intl.dart';

String formatDateString(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';

  try {
    final date = DateTime.parse(isoDate);
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar') {
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    } else {
      return DateFormat('dd MMM yyyy', 'en').format(date);
    }
  } catch (_) {
    return isoDate;
  }
}
