import 'dart:math';

import 'package:get/get.dart';

class LoadingService extends GetxService {
  final RxInt _count = 0.obs;

  bool get isLoading => _count.value > 0;

  void show() => _count.value += 1;

  void hide() => _count.value = max(0, _count.value - 1);

  void reset() => _count.value = 0;

  Future<T> run<T>(Future<T> Function() task, {bool enabled = true}) async {
    if (!enabled) return await task();
    show();
    try {
      return await task();
    } finally {
      hide();
    }
  }
}
